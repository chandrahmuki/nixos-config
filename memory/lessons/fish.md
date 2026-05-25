# Fish Shell — Lessons Learned

- 2026-05-25: La commande `string match` de Fish ne prend pas d'option `-x` (ou `--exact`). Par défaut, sans option regex (`-r`) ou glob (`*`), elle effectue déjà une correspondance exacte sur la chaîne entière.
- 2026-05-25: Toujours tester la syntaxe des scripts et fonctions Fish générés à l'aide de commandes comme `fish -c "help string"` ou en les évaluant dans un sous-processus Fish avant de valider la configuration.
