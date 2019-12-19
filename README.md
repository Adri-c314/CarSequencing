# Projet de Car sequencing 
Université de Nantes - Master 2 ORO - Année 2019/2020.

## Structure générale du dossier
```
Rapport.pdf                     - Rapport du projet
Presentation_Renault_1.pdf      - Présentation finale
Presentation_Renault_preli.pdf  - Présentation intermédiaire
test_plot.py                    - Le fichier appelant pyplot pour les graphiques
instances.txt                   - la liste des instances
fonction-thad.jl                - Element de test a inclure dans le code
\hv-1.3-src                     - Le dossier src fourni pour l'hyper volume
\Input                          - L'ensemble des instances
\Output                         - L'ensemble des sorties
\Src                            - L'ensemble du code julia
  \genetic                      - Toutes les fonctions liées à l'algorithme génétique
  \Main                         - Dossier du fichier main.jl contenant tous nos différents main
  \Metaheuristique              - Dossier contenant tous les fichiers liés à la VFLS
  \PLS&NDTree                   - Dossier contenant tous les fichiers liés au NDTree et à la PLS
  \Util                         - Dossier contenant tous les fichiers liés aux fonctions utiles Ex : ecriture
```

## Commandes d'éxécutions

```include("./src/Main/main.jl")```

L'inclusion du main inclue récursivement tout le projet.

Le fichier main est composé de 4 fonctions principales dont les paramètres sont entièrement définis dans le fichier main.jl :
```
main()                           - La fonction lancant la VFLS
mainGenetic()                    - La fonction lançant l'algorithme génétique
mainGeneticPLS()                 - La fonction lançant le genetique puis la PLS sur les solutions obtenues
mainTestPLS()                    - La fonction lançant juste la PLS sur la population elite
```
