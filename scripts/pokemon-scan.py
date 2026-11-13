#!/usr/bin/env python3
"""Releve quotidien des prix Cardmarket (EUR) via TCGdex.

Ecrit ~/.local/share/pokemon-tracker/AAAA-MM-JJ.json : une liste de cartes
(id, nom, set, rarete, tendance, moyennes 1/7/30 jours, prix bas).
Relancer le meme jour remplace le fichier du jour.

Usage : pokemon-scan.py [--since AAAA-MM-JJ] [--min-trend EUR] [--out DOSSIER]
"""
import argparse
import datetime as dt
import json
import os
import sys
import time
import urllib.request
from concurrent.futures import ThreadPoolExecutor

API = "https://api.tcgdex.net/v2/en"


def get(path):
    req = urllib.request.Request(API + path, headers={"User-Agent": "pokemon-tracker/0.1"})
    for attempt in range(4):
        try:
            with urllib.request.urlopen(req, timeout=30) as r:
                return json.load(r)
        except Exception:
            time.sleep(1.5 * (attempt + 1))
    return None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--since", default="2020-11-01")
    ap.add_argument("--min-trend", type=float, default=20.0)
    ap.add_argument("--out", default=os.path.join(
        os.environ.get("XDG_DATA_HOME", os.path.expanduser("~/.local/share")), "pokemon-tracker"))
    args = ap.parse_args()

    started = time.time()
    sets = get("/sets")
    if not sets:
        sys.exit("TCGdex injoignable : liste des sets vide")
    details = [d for d in (get("/sets/" + s["id"]) for s in sets) if d and d.get("releaseDate", "") >= args.since]

    rows, failed = [], 0
    for d in details:
        ids = [c["id"] for c in d["cards"]]
        with ThreadPoolExecutor(8) as ex:
            cards = list(ex.map(lambda i: get("/cards/" + i), ids))
        for i, c in zip(ids, cards):
            if c is None:
                failed += 1
                continue
            cm = (c.get("pricing") or {}).get("cardmarket")
            if not cm or not cm.get("trend") or cm["trend"] < args.min_trend:
                continue
            rows.append({
                "id": c["id"], "name": c["name"], "set": d["name"], "released": d["releaseDate"],
                "rarity": c.get("rarity"), "trend": cm.get("trend"), "avg": cm.get("avg"),
                "low": cm.get("low"), "avg1": cm.get("avg1"), "avg7": cm.get("avg7"),
                "avg30": cm.get("avg30"), "updated": cm.get("updated"),
            })

    if failed > 0.02 * max(1, len(rows) + failed):
        sys.exit(f"{failed} cartes en echec : releve non enregistre")

    os.makedirs(args.out, exist_ok=True)
    path = os.path.join(args.out, dt.date.today().isoformat() + ".json")
    tmp = path + ".tmp"
    with open(tmp, "w") as f:
        json.dump(rows, f, separators=(",", ":"))
    os.replace(tmp, path)
    print(f"{len(rows)} cartes, {len(details)} sets, {failed} echecs, {time.time() - started:.0f}s -> {path}")


if __name__ == "__main__":
    main()
