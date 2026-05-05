# Dev Tools — Lessons Learned

- 2026-05-04: Bun/TS + bun:sqlite = stack ideal pour un CLI rapide, leger, zero dependance externe
- 2026-05-04: Emojis dans console.log peuvent bloquer la sortie terminal — preferer texte ASCII
- 2026-05-04: Regex generiques pour extraction universelle de code = 80% des cas couverts sans grammar AST
- 2026-05-04: D3.js doit etre inline (pas CDN/script src) pour compatibilite file:// — CORS bloque sinon
- 2026-05-04: D3 forceLink utilise source/target en interne, pas from_id/to_id — mapper avant simulation
- 2026-05-04: Graphify = concept interessant mais overkill pour Nix pur, pas de support Nix natif
- 2026-05-05: Nix `programs.X.enable = true;` = attribute_path dans tree-sitter, pas select_expression standalone
- 2026-05-05: Incremental build avec SHA-256 content-hash = ~90% skip sur 2eme run
- 2026-05-05: BFS par profondeur (impact) deduplique les edges multiples vers le meme noeud
