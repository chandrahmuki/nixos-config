# Workflow agents pour NixOS

Ce fichier s'applique a toutes les interventions dans ce depot. Le but prioritaire
est un resultat observable et fiable, pas seulement une configuration qui evalue.

## Responsabilite de l'agent principal

- L'agent principal reste responsable du resultat final, meme si un sous-agent a
  inspecte ou modifie le code.
- Il relit les changements, execute lui-meme les validations disponibles et
  confronte les journaux au comportement reel.
- Il ne delegue jamais le test d'acceptation final a un sous-agent.
- Le retour utilisateur fait foi pour le comportement visible. Un journal qui dit
  `success` ne contredit pas un texte absent, une fenetre bloquee ou un raccourci
  inoperant.

## Routage des modeles

- **Luna** : inventaire en lecture seule, recherche ciblee, documentation, mise en
  forme et modification mecanique isolee a faible risque.
- **Terra Medium** : choix par defaut pour une modification Nix bornee, un
  diagnostic reproductible ou une implementation dans un petit nombre de fichiers.
- **Terra High** : interaction entre service, session utilisateur, materiel ou
  application desktop lorsque les frontieres sont deja comprises.
- **Sol High** : packaging complexe, integration Wayland/portails/audio/input,
  changement transversal, ambiguite d'architecture, ou nouvelle analyse apres deux
  iterations ayant echoue pour la meme cause.
- **Astra** : hors du workflow normal. Ne l'utiliser que sur demande explicite ou
  pour un blocage architectural exceptionnel apres constitution d'un dossier de
  preuves compact.

Changer de modele ne remplace jamais un test. Une tache simple correctement testee
reste chez Terra ou Luna ; une tache mal definie ne devient pas fiable uniquement
en passant a Sol.

## Toujours faire

1. **Inspecter avant de modifier**
   - Lire `git status --short` et preserver les changements sans rapport.
   - Rechercher d'abord avec `rg` les declarations, services, raccourcis, paquets et
     restes d'anciennes tentatives.
   - Verifier l'etat actif separement de l'etat declare.

2. **Definir la preuve attendue avant l'implementation**
   - Paquet CLI : commande reellement executee avec un resultat verifiable.
   - Service : unite active, journaux propres et fonction exercee.
   - Application desktop : lancement reel puis parcours utilisateur complet.
   - Audio, raccourci, focus ou Wayland : tester le scenario exact, y compris le
     changement de fenetre ou de workspace lorsqu'il fait partie du probleme.
   - Interface visuelle (Quickshell, Hyprland, widget, panneau, notification ou
     layout) : definir une capture d'ecran du rendu actif et les elements qui
     doivent etre visibles, dans leur ordre et avec leurs etats attendus.

3. **Faire le plus petit changement coherent**
   - Une hypothese principale par iteration.
   - Ne toucher qu'aux fichiers necessaires.
   - Mettre en stage les nouveaux fichiers appartenant a la tache avant une
     evaluation de flake Git locale, sans embarquer les changements sans rapport.

4. **Passer les niveaux de validation sans les confondre**
   - Declaration inspectee.
   - Evaluation et build reussis.
   - Activation reussie.
   - Etat runtime verifie.
   - Test d'acceptation de bout en bout reussi.

5. **Valider une configuration NixOS**
   - Executer `git diff --check`.
   - Construire avec :
     `nix build .#nixosConfigurations.muggy-nixos.config.system.build.toplevel --no-link --print-out-paths`.
   - Utiliser uniquement le chemin affiche par `--print-out-paths`.
   - Pour l'activation, demander a l'utilisateur d'executer `nos` dans son terminal
     visible si sudo exige un mot de passe.
   - Apres activation, verifier `/run/current-system`, les executables, groupes,
     services, processus et raccourcis concernes.

6. **Tester le vrai workflow**
   - Lancer l'application dans la session graphique reelle.
   - Executer autant que possible le parcours complet sans intervention humaine.
   - Si une action physique est indispensable (parler, brancher un casque, observer
     une surface graphique), automatiser tout le reste, demander une seule action
     precise, puis inspecter immediatement les journaux et la sortie produite.
   - Ne conclure au succes que lorsque l'effet attendu est visible ou directement
     mesurable.

7. **Preuve visuelle obligatoire pour toute modification d'interface**
   - Capturer le rendu de la vraie session graphique apres le rechargement actif ;
     une capture de code, un apercu statique ou une image de reference ne compte
     pas.
   - Ouvrir et examiner cette capture avant de conclure. Ne pas se contenter de
     creer le fichier image : verifier explicitement chaque element attendu, son
     ordre, sa presence, son espacement, son etat ouvert/ferme et l'absence de
     regression visible.
   - Tester les etats pertinents, pas uniquement l'etat au repos : au minimum
     ouverture, fermeture, remplacement entre panneaux et le scenario de focus ou
     workspace signale par l'utilisateur.
   - Si la capture ne permet pas d'identifier sans ambiguite un element (par
     exemple une icone tray confondue avec une icone reseau), le test echoue :
     ajouter une verification ciblee ou rendre l'etat lisible, puis recapturer.
   - Ne jamais annoncer un changement graphique comme termine sans au moins une
     capture active relue et une preuve de l'interaction modifiee.

8. **Boucler apres un echec**
   - Capturer l'erreur exacte et l'etat runtime.
   - Identifier le maillon en echec avant toute nouvelle installation.
   - Si le retour utilisateur contredit l'hypothese courante, invalider cette
     hypothese immediatement et revenir aux mesures ; ne pas rationaliser la
     contradiction.
   - Corriger la cause la plus petite.
   - Rejouer exactement le meme test d'acceptation.
   - Continuer jusqu'au succes ou a un blocage externe demontre. Apres deux echecs
     comparables, arreter les ajustements locaux, elargir le diagnostic et escalader
     vers Sol High si la complexite le justifie.

## Diagnostic causal obligatoire

- Definir d'abord le symptome comme un scenario observable : action exacte, composant
  concerne, resultat attendu, resultat obtenu et moment ou ils divergent.
- Reconstituer la chaine complete dans son ordre d'execution : sources declarees,
  fichiers generes, generation active, executable et processus reels, environnement,
  hooks de demarrage, caches, IPC/DBus/socket, interaction utilisateur, puis sortie
  visible ou mesurable. Inventorier tous les producteurs capables de modifier l'etat.
- Comparer a chaque maillon la valeur attendue et la valeur reelle. Une declaration,
  un fichier genere ou un journal correct ne prouve jamais que l'etat final n'a pas
  ete remplace plus tard.
- Distinguer explicitement `observation`, `hypothese` et `cause prouvee`. Ne declarer
  une cause qu'apres un test discriminant qui neutralise ou modifie une seule variable
  et fait suivre au symptome le resultat prevu.
- Utiliser lorsque possible un controle positif et un controle negatif : composant
  affecte contre composant sain, processus existant contre nouveau processus, etat
  avant contre apres, workflow minimal contre workflow complet.
- Pour tout mecanisme persistant ou rechargeable a chaud, tester les deux cycles :
  mise a jour d'une instance deja ouverte, puis nouvelle instance apres la mise a jour.
- Verifier l'identite de ce qui est reellement teste : generation active, executable,
  version, PID, unite, fenetre, fichier de configuration charge, dependances et route
  d'entree/sortie. Ne pas diagnostiquer un composant seulement parce qu'il etait celui
  attendu ou declare.
- Pour chaque correction, obtenir une preuve avant/apres sur le scenario exact : le
  symptome doit etre observe avant, disparaitre apres la modification minimale, puis
  rester absent apres recreation ou redemarrage du seul composant concerne.
- Si le test ne distingue pas plusieurs causes possibles, il est insuffisant : ajouter
  une mesure ou un controle jusqu'a pouvoir eliminer les hypotheses concurrentes.
- Un sous-agent ou un modele plus puissant fournit une hypothese, pas une preuve.
  L'agent principal rejoue lui-meme le test discriminant avant de retenir sa conclusion.

## Ne jamais faire

- Ne jamais annoncer `c'est fait`, `c'est corrige` ou `ca marche` apres une simple
  edition, evaluation ou construction.
- Ne jamais presenter un build comme une preuve d'activation ou une activation
  comme une preuve de comportement graphique.
- Ne jamais deduire un chemin de sortie Nix a partir du nom d'un fichier `.drv`.
- Ne jamais ouvrir un prompt sudo dans un terminal de fond inaccessible.
- Ne jamais demander ni accepter le mot de passe de l'utilisateur.
- Ne jamais faire confiance a un succes interne de collage, raccourci ou portail
  sans verifier l'effet dans l'application cible.
- Ne jamais installer plusieurs solutions concurrentes pour masquer un diagnostic
  incomplet.
- Ne jamais ajouter Flatpak, AppImage, portail, service, groupe privilegie, script
  ou daemon avant d'avoir prouve pourquoi le chemin deja present est insuffisant.
- Ne jamais changer simultanement le micro, le modele, le raccourci et la methode
  d'insertion : isoler les variables.
- Ne jamais laisser un processus, fichier utilisateur, raccourci ou paquet d'une
  tentative abandonnee sans faire un audit final cible.
- Ne jamais supprimer les changements existants, les donnees utilisateur ou les
  generations de rollback sans autorisation explicite et cibles verifies.
- Ne jamais redemarrer Quickshell, Hyprland ou la session complete si le composant
  modifie ne le requiert pas.
- Ne jamais cacher une dette de preuve : indiquer clairement ce qui est inspecte,
  construit, active, teste ou encore non verifie.
- Ne jamais inferrer qu'une interface est correcte parce qu'une capture existe :
  l'agent principal doit la lire et comparer le rendu aux criteres attendus avant
  de la citer comme preuve.
- Ne jamais exclure un producteur potentiel uniquement parce que sa directive est
  absente de la configuration de l'application : une couche ulterieure peut agir.
- Ne jamais attribuer une cause sur la seule ressemblance visuelle, un journal
  `success`, une correlation temporelle ou une configuration statique ; isoler la
  variable et mesurer le resultat final.
- Ne jamais ecrire `cause etablie` tant que le test discriminant correspondant n'a
  pas ete execute avec succes.

## Rapport de fin obligatoire

Toute livraison NixOS doit terminer par un resume de ce type :

```text
Declare : oui/non, avec emplacement
Construit : oui/non, avec commande et resultat
Active : oui/non, avec preuve de generation
Runtime : oui/non, avec processus/service/journal
Test utilisateur reel : oui/non, avec scenario execute
Preuve visuelle : oui/non, avec capture active relue et etats verifies
Restes ou limites : liste explicite, ou aucun
```

Si le dernier niveau necessaire vaut `non`, le travail n'est pas annonce comme
termine. L'agent poursuit la boucle lorsqu'il peut agir, ou expose le blocage exact
sans transformer une validation partielle en succes.
