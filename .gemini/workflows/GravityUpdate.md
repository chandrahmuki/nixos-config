---
description: Met à jour automatiquement la version et le hash du package local Google Antigravity
---

# 🚀 Workflow: /GravityUpdate

Ce workflow automatise entièrement la vérification et la mise à jour du package local Google Antigravity local sans nécessiter la moindre intervention manuelle pour récupérer la version ou le hash.

// turbo
1. Exécute la commande suivante pour récupérer la dernière version, calculer le hash SRI, mettre à jour le fichier `default.nix` et l'ajouter à l'index Git :
```bash
cd /home/david/nixos-config
echo "Recherche de la dernière version d'Antigravity..."
VERSION=$(curl -sL --compressed "https://antigravity.google/download/linux" | tr -d '\000' | grep -oP 'antigravity/stable/\K[0-9.]+-[0-9]+' | head -1)

if [ -z "$VERSION" ]; then 
  echo "Erreur: Impossible de trouver la version."
  exit 1
fi

echo "Nouvelle version détectée : $VERSION"
echo "Récupération de l'archive (500Mb+) et calcul du hash SHA256 (cela peut prendre quelques secondes)..."

URL="https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/${VERSION}/linux-x64/Antigravity.tar.gz"
HASH_RAW=$(nix-prefetch-url "$URL" 2>/dev/null)
HASH_SRI=$(nix hash to-sri --type sha256 "$HASH_RAW")

echo "Mise à jour du fichier default.nix avec le hash : $HASH_SRI"

sed -i "s/version ? \".*\"/version ? \"$VERSION\"/" pkgs/google-antigravity/default.nix
sed -i "s/sha256 ? \".*\"/sha256 ? \"$HASH_SRI\"/" pkgs/google-antigravity/default.nix

git add pkgs/google-antigravity/default.nix
echo "✅ Mise à jour terminée dans les fichiers et ajoutée à git (git add) !"
```

2. Demande à l'utilisateur de lancer `nos` dans son terminal pour appliquer la mise à jour (reconstruction NixOS).
3. Dès que l'utilisateur confirme le bon fonctionnement, propose de finaliser avec un commit (ex: `git commit -m "feat(pkgs): update google-antigravity to $VERSION"`) et de le pousser.
