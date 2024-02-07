# Script R : meteo_quotidienne

 Ce script permet de récupérer les relevés de température et de précipitations quotidienns de Météo France publiés sur data.gouv.fr                              
 Il traite les données des champs :                                    
   * TM : moyenne quotidienne des températures horaires sous abri (en °C et 1/10)           
   * TN : température minimale sous abri dans l’heure (en °C et 1/10)  
   * TX : température maximale sous abri dans l’heure (en °C et 1/10)  
   * RR: quantité de précipitation tombée en 24 heures (de 06h FU le jour J à 06h FU le jour J+1). La valeur relevée à J+1 est affectée au jour J (en mm et 1/10)

## Descriptif du contenu

* Racine : emplacement du projet R --> "METEO_HORAIRE.Rproj"
* Un dossier "data" pour stocker les données téléchargées par le script
* Un dossier "doc" contenant le descriptif des champs
* Un dossier "result" pour le stockage du résultat
* Un dosssier script qui contient :
  * prog_meteo.R --> script principal
  * librairie.R --> script contenant les librairies utiles au programme
  * donnees_meteo.R --> script de téléchargement et de mise en forme des données
  * suppression_gitkeep.R --> script de suppression des .gitkeep
  * script en cours de développement et non appelé dans le script principal :
      * carte_station.R --> création d'une carte des stations actives et inactives
      * graph_meteo.R --> mise en forme de graphique des températures et des précipitations par station

## Fonctionnement

1. Modifier la valeur affectée à la variable "sel_dep" avec le numéro du département souhaité
2. Lancer le script intitulé "prog_meteo" qui se trouve dans le dossier "script"

## Résultat

Le dossier "result" contiendra:
  * un fichier csv nommé "temperature" avec les relevés de températures toutes stations confondues
  * un fichier csv nommé "temperature_station_active" avec les relevés de températures des stations actives
  * un fichier csv nommé "precipitation" avec les relevés de précipitations toutes stations confondues
  * un fichier csv nommé "precipitation_station_active" avec les relevés de précipitations des stations actives
  * un fichier csv nommé "station_meteo" la liste des stations actives et inactives présentent sur le département
