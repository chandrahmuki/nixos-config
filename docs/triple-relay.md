# 💎 Système de Relais Triple (Triple Relay)

Le projet utilise un système de collaboration agentique basé sur trois rôles distincts pour garantir la qualité et la pérennité de la configuration.

## Les Trois Rôles

1.  **Codeur (Toi/IA)** : Se concentre à 100% sur l'implémentation, la correction de bugs et les tests de validation.
2.  **Auditeur (IA - `/audit`)** : Effectue une revue de code rigoureuse. Vérifie la conformité à `GEMINI.md`, la propreté du code et propose des optimisations sans modifier le code lui-même.
3.  **Archiviste (IA - `/archive`)** : S'occupe de la capitalisation du savoir. Met à jour les **Knowledge Items (KI)** pour que l'IA garde une mémoire technique précise du projet.

## Commandes Slash

-   **/auto-doc** : À utiliser après un changement fonctionnel pour synchroniser la documentation et préparer le terrain pour l'IA suivante.
-   **/audit** : Pour lancer une analyse de qualité sur les changements récents.
-   **/archive** : Pour enregistrer les nouveaux apprentissages techniques.

## Philosophie : Focus Chirurgical
Chaque étape du relais doit être concise et efficace (**5-10 tours maximum**). On privilégie la précision et la mise à jour constante du savoir technique.
