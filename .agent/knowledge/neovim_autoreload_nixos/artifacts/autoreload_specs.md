# Neovim Autoreload on NixOS

## Problématique
Sur NixOS, la configuration de Neovim est souvent gérée via Home Manager ou directement dans des fichiers stockés dans le Nix store (lecture seule). L'utilisation de fichiers séparés pour les `autocmds` peut poser des problèmes de résolution de modules (`lua/core/autocmds.lua`) si le chemin n'est pas proprement géré dans l'environnement Nix.

## Solution Technique
Pour garantir la fiabilité de l'autoreload (rechargement automatique des fichiers modifiés à l'extérieur, comme par l'IA), il est recommandé d'inliner les `autocmds` critiques directement dans le fichier `init.lua` ou d'utiliser des chemins absolus vers le store.

### Configuration des Options (`options.lua`)
Activer `autoread` et réduire `updatetime` pour une détection plus fréquente.

```lua
-- Autoreload settings (for external changes)
vim.opt.autoread = true
vim.opt.updatetime = 300
```

### Autocmd d'Autoreload (`init.lua`)
Inliner l'appel `checktime` pour forcer Neovim à vérifier l'état du disque lors de certains événements (gain de focus, mouvement du curseur).

```lua
-- Recharger automatiquement le fichier s'il change sur le disque
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI", "FocusGained", "BufEnter" }, {
  pattern = "*",
  command = "checktime",
})
```

## Pièges Évités (Gotchas)
- **Module Resolution**: Éviter `require("core.autocmds")` si le fichier est généré dynamiquement dans un environnement où le `LUA_PATH` n'est pas stable par rapport au Nix store. L'inlining est la solution la plus robuste pour ces petites configurations critiques.
- **Race conditions**: L'utilisation combinée de `CursorHold` et `checktime` garantit que Neovim reflète les modifications de l'assistant IA presque instantanément.
