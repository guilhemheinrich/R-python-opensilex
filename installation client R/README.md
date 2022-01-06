# Installation de l'environnement

Télécharger et installer [conda](https://docs.conda.io/projects/conda/en/latest/user-guide/install/index.html#installing-in-silent-mode). Conda est un gestionnaire d'environnement, ce qui permet une meilleur pérennité, tracabilité, reproductibilité du code: il s'agit d'une (très) bonne pratique.

Une fois conda installé, on créé l'environnement "vierge". Dans cet exemple, j'ai choisi la version 3.6 de R (qui fonctionne).

```sh
conda create -n opensilex-R r-base=3.6
```

# Installation des packages R

Une fois l'environnement conda créé, on l'active avec:

```sh
conda activate opensilex-R
```

Avec bash (et powerhsell), si tout fonctionne correctement, il devrait y avoir le nom de l'environnement entre parenthèse en préfixe de chaque ligne dans le terminal.

Ensuite on installe la dernière version (autogénéré) du client R avec la liste de commande contenu dans le fichier ./installation.R.

En ce mettant au niveau de la racine de ce fichier:
```sh
Rscript ./installation.R
```

# Test

Pour tester que tout fonctionne normalement, on éxécute le script d'exemple dans le répertoire test:

```sh
Rscript ./test/sinfonia.R
```