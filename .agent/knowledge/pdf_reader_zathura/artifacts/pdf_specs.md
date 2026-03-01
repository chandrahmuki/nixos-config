# 📄 Module PDF (Zathura)

## Contexte
Zathura est un lecteur de PDF léger, rapide et pilotable au clavier (Vim-style). Il est privilégié pour sa sobriété et son intégration parfaite sous Wayland.

## Configuration
Le module `modules/pdf.nix` configure Zathura avec un thème sombre et des options d'ergonomie :

```nix
programs.zathura = {
  enable = true;
  options = {
    selection-clipboard = "clipboard";
    recolor = true; # Active le mode sombre par défaut
    recolor-keephue = true;
    
    # Thème Sombre Premium (Catppuccin-like)
    default-bg = "#1e1e2e";
    default-fg = "#cdd6f4";
    recolor-lightcolor = "#1e1e2e";
    recolor-darkcolor = "#cdd6f4";
    # ... autres options de couleurs pour barres d'état et d'entrée
  };
};
```

## Raccourcis Utiles
- **`Ctrl+r`** : Basculer entre le mode couleurs originales et le mode recoloré (sombre).
- **`j/k`** : Défilement bas/haut.
- **`/`** : Recherche dans le document.

## Outils liés
- **`qpdf`** : Pour déprotéger des PDFs si besoin (ex: `qpdf --decrypt in.pdf out.pdf`).

## Maintenance
Le module est importé dans `home.nix`. Pour modifier les couleurs ou les comportements, éditer `modules/pdf.nix`.
