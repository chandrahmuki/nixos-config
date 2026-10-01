#!/usr/bin/env python3
"""Local Laya model recommendation followed by an explicit Codex launch."""

from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import sys


QUESTIONS = {
    "route": {
        "type": "choice",
        "instructions": (
            "Choose the least powerful coding model sufficient to complete this task reliably. "
            "Judge the requested work, not which model is strongest in general."
        ),
        "criteria": {
            "luna": (
                "Small, explicit, isolated work: explanation, typo, simple mechanical edit, "
                "or a clearly scoped change with an obvious check."
            ),
            "sol": (
                "Ordinary software engineering needing repository investigation, debugging, "
                "multiple steps or files, implementation, or meaningful tests."
            ),
            "astra": (
                "Genuinely difficult or ambiguous architecture, security/permissions, "
                "high-impact migration, or broad end-to-end judgment that warrants the strongest model."
            ),
            "clarify": (
                "Essential requirements or context are missing; ask the user before choosing a model."
            ),
        },
    }
}

WORKFLOW_QUESTIONS = {
    "complexity": {
        "type": "choice",
        "instructions": "Classify the software task by the capability it needs.",
        "criteria": {
            "SMALL": "A short, explicit, isolated task with an obvious deterministic check.",
            "MEDIUM": "Normal implementation or debugging requiring several steps, files, or tests.",
            "HIGH": "Broad, uncertain, cross-cutting work requiring careful sustained judgment.",
            "ESCALATE": "Architecture, security, permissions, major migration, or unresolved repeated failure requires a stronger reviewer or human decision.",
        },
    },
    "luna_effort": {
        "type": "choice",
        "instructions": "If Luna is sufficient, choose the minimum reasoning effort it needs.",
        "criteria": {
            "LOW": "Clear, bounded, mechanical work or a direct factual explanation.",
            "MEDIUM": "A coordinated but still well-scoped implementation or investigation.",
            "HIGH": "Harder analysis within a task that remains safe and suitable for Luna.",
            "NOT_LUNA": "The work should use another model, escalate, or wait for clarification.",
        },
    },
    "next_action": {
        "type": "choice",
        "instructions": "Given the current implementation cycle and its evidence, choose the next control action.",
        "criteria": {
            "CONTINUE": "The current attempt is progressing and a bounded implementation step remains.",
            "RETRY": "A specific, plausibly transient or locally correctable failure justifies one targeted retry.",
            "VERIFY": "Run or obtain a deterministic or user-visible check before deciding anything else.",
            "ESCALATE": "Risk, scope growth, repeated comparable failure, or uncertainty requires a stronger model or human review.",
            "COMPLETE": "The requested behavior, relevant checks, diff scope, and any required acceptance evidence are all satisfied.",
        },
    },
    "blast_radius": {
        "type": "choice",
        "instructions": "Assess the observed change scope against the request, not just the number of files.",
        "criteria": {
            "STABLE": "Changes remain within the requested component and expected dependencies.",
            "GROWING": "The diff crosses additional modules, runtime boundaries, or user-visible behavior beyond the original scope.",
            "LARGE": "The change affects architecture, security, permissions, shared configuration, or many independent consumers.",
        },
    },
    "escalation": {
        "type": "noul",
        "instructions": "Does the supplied evidence justify escalation to a stronger model or a human reviewer now?",
    },
    "completion": {
        "type": "noul",
        "instructions": "Does the supplied evidence support reporting the requested task as complete?",
    },
}

WORKFLOW_FIXTURES = [
    {
        "name": "simple task before implementation",
        "state": "Task: Correct one typo in a README heading. Evidence: no diff exists yet; no check has run.",
        "expected": {"complexity": "SMALL", "luna_effort": "LOW", "next_action": "VERIFY", "blast_radius": "STABLE", "escalation": False, "completion": False},
    },
    {
        "name": "bounded implementation with passing test",
        "state": "Task: Fix a parser edge case and add one regression test. Evidence: one intended source file and one test changed; targeted test and lint passed; requested behavior is reproduced and verified; no unresolved failures.",
        "expected": {"complexity": "MEDIUM", "luna_effort": "MEDIUM", "next_action": "COMPLETE", "blast_radius": "STABLE", "escalation": False, "completion": True},
    },
    {
        "name": "first targeted check failure",
        "state": "Task: Fix a localized parser bug. Attempt 1. Evidence: targeted regression test fails with a new assertion mismatch; diff is limited to the parser and its test; root cause is not yet known.",
        "expected": {"complexity": "MEDIUM", "luna_effort": "MEDIUM", "next_action": "RETRY", "blast_radius": "STABLE", "escalation": False, "completion": False},
    },
    {
        "name": "same failure after retry",
        "state": "Task: Fix a localized parser bug. Attempt 2 after one targeted retry. Evidence: the same regression test still fails for the same reason; two comparable fixes were attempted; no unrelated files changed.",
        "expected": {"complexity": "ESCALATE", "luna_effort": "NOT_LUNA", "next_action": "ESCALATE", "blast_radius": "STABLE", "escalation": True, "completion": False},
    },
    {
        "name": "scope grows across components",
        "state": "Task: Adjust spacing in one Quickshell pill. Evidence: the diff now changes shared theme tokens, two widgets, session startup, and unrelated terminal configuration; no request authorized those extra areas.",
        "expected": {"complexity": "HIGH", "luna_effort": "NOT_LUNA", "next_action": "ESCALATE", "blast_radius": "GROWING", "escalation": True, "completion": False},
    },
    {
        "name": "security and permissions boundary",
        "state": "Task: Redesign secret handling, authentication, and user permissions across services. Evidence: security-sensitive architecture and irreversible credential migration are in scope; no implementation or independent security review exists yet.",
        "expected": {"complexity": "ESCALATE", "luna_effort": "NOT_LUNA", "next_action": "ESCALATE", "blast_radius": "LARGE", "escalation": True, "completion": False},
    },
    {
        "name": "visual acceptance still missing",
        "state": "Task: Change a visible desktop widget. Evidence: source diff and compiler pass; the running session was not reloaded and there is no inspected screenshot or interaction test.",
        "expected": {"complexity": "MEDIUM", "luna_effort": "HIGH", "next_action": "VERIFY", "blast_radius": "STABLE", "escalation": False, "completion": False},
    },
    {
        "name": "NixOS activation still pending",
        "state": "Task: Add a user shell command in NixOS. Evidence: declaration evaluates and the system closure builds; the new generation has not been activated and the command has not been exercised from the active profile.",
        "expected": {"complexity": "MEDIUM", "luna_effort": "MEDIUM", "next_action": "VERIFY", "blast_radius": "STABLE", "escalation": False, "completion": False},
    },
]


def classify(prompt: str) -> tuple[str, dict[str, float], str]:
    try:
        from laya import Router
    except ImportError as exc:
        raise RuntimeError(
            "Laya n'est pas installé dans son environnement isolé. "
            "Relance la commande pour terminer l'installation."
        ) from exc

    result = Router(max_loaded=1).predict(prompt, QUESTIONS)
    answer = result["answers"]["route"]
    choice = answer.get("choice")
    probabilities = answer.get("probabilities", {})
    if choice not in {"luna", "sol", "astra", "clarify"}:
        raise RuntimeError(f"Réponse Laya inattendue: {json.dumps(answer, ensure_ascii=False)}")
    model = result.get("routing", {}).get("model", "inconnu")
    return choice, probabilities, model


def workflow_test() -> int:
    from laya import Router

    requests = [
        {"state": fixture["state"], "questions": WORKFLOW_QUESTIONS}
        for fixture in WORKFLOW_FIXTURES
    ]
    results = Router(max_loaded=1).predict_batch(requests)
    totals = {key: 0 for key in WORKFLOW_QUESTIONS if key != "luna_effort"}
    # Effort is still reported separately because it only applies on Luna routes.
    totals["luna_effort"] = 0
    count = len(WORKFLOW_FIXTURES)
    for fixture, result in zip(WORKFLOW_FIXTURES, results, strict=True):
        answers = result["answers"]
        actual = {
            "complexity": answers["complexity"].get("choice"),
            "luna_effort": answers["luna_effort"].get("choice"),
            "next_action": answers["next_action"].get("choice"),
            "blast_radius": answers["blast_radius"].get("choice"),
            "escalation": answers["escalation"].get("noul", 0.0) >= 0.5,
            "completion": answers["completion"].get("noul", 0.0) >= 0.5,
        }
        expected = fixture["expected"]
        for key in totals:
            totals[key] += actual[key] == expected[key]
        print(f"\n{fixture['name']}")
        print("  attendu : " + json.dumps(expected, ensure_ascii=False))
        print("  Laya    : " + json.dumps(actual, ensure_ascii=False))
        print(f"  checkpoint: {result.get('routing', {}).get('model', 'inconnu')}")

    print("\nCorrespondance sur ces scénarios (évaluation indicative, pas un benchmark):")
    for key, correct in totals.items():
        print(f"  {key}: {correct}/{count}")
    print("Les sorties sont consultatives : aucun retry, modèle ou état de complétion n'a été appliqué.")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(
        description=(
            "Classe une tâche localement avec Laya, puis recommande un modèle Codex. "
            "Le prompt n'est envoyé à Codex qu'après confirmation explicite."
        )
    )
    parser.add_argument(
        "--route-only",
        action="store_true",
        help="affiche la recommandation sans lancer Codex",
    )
    parser.add_argument(
        "--workflow-test",
        action="store_true",
        help="évalue les décisions du cycle complet sur huit scénarios, sans lancer Codex",
    )
    parser.add_argument(
        "prompt",
        nargs=argparse.REMAINDER,
        help="tâche à effectuer; place-la après -- si elle commence par un tiret",
    )
    args = parser.parse_args()
    if args.workflow_test:
        try:
            return workflow_test()
        except Exception as exc:
            print(f"codex-laya workflow-test: {exc}", file=sys.stderr)
            return 2

    prompt = " ".join(args.prompt).strip()
    if prompt.startswith("-- "):
        prompt = prompt[3:]
    if not prompt:
        parser.error("fournis la tâche, par exemple: codex-laya --route-only 'Corrige une faute dans README'")

    try:
        route, probabilities, checkpoint = classify(prompt)
    except Exception as exc:  # present model/runtime failures without a misleading fallback
        print(f"codex-laya: {exc}", file=sys.stderr)
        return 2

    print(f"Laya local ({checkpoint}) recommande : {route}")
    if probabilities:
        ranking = sorted(probabilities.items(), key=lambda item: item[1], reverse=True)
        print("Scores : " + ", ".join(f"{name} {score:.0%}" for name, score in ranking))
    print("Les scores Laya ne sont pas calibrés pour le routage des tâches Codex.")

    if route == "clarify":
        print("Pas de lancement : précise la demande avant de choisir un modèle.")
        return 0
    if args.route_only:
        return 0
    if not sys.stdin.isatty():
        print("Pas de terminal interactif; utilise --route-only ou relance dans un terminal.", file=sys.stderr)
        return 2
    if not shutil.which("codex"):
        print("codex-laya: commande codex introuvable dans PATH", file=sys.stderr)
        return 2

    model = f"gpt-6-{route}"
    answer = input(f"Lancer `codex exec` avec {model} et workspace-write ? [y/N] ").strip().lower()
    if answer not in {"y", "yes", "o", "oui"}:
        print("Annulé; aucune requête Codex lancée.")
        return 0

    return subprocess.run(
        ["codex", "exec", "--sandbox", "workspace-write", "--model", model, prompt],
        check=False,
    ).returncode


if __name__ == "__main__":
    raise SystemExit(main())
