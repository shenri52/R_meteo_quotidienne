######################################################################### 
# Ce script permet de récupérer les relevés de température et de        #
# précipitations quoidienne de Météo France.                            #
# Il traite les données des champs :                                    #
#   - TM : moyenne quotidienne des températures horaires sous abri      #
# (en °C et 1/10)                                                       #
#   - TN : température minimale sous abri dans l’heure (en °C et 1/10)  #
#   - TX : température maximale sous abri dans l’heure (en °C et 1/10)  #
#   - RR: quantité de précipitation tombée en 24 heures (de 06h FU le   #
# jour J à 06h FU le jour J+1). La valeur relevée à J+1 est affectée au #
# jour J (en mm et 1/10)                                                #
#########################################################################
# Fonctionnement :                                                      #
#     1. Téléchargement des données sur data.gouv.fr                    #
#     2. Mise en forme des données méteos publiées par météo france     #
#     Les données sont téléchargées dans le dossier 'data'              #
#                                                                       #
# Le descriptif du contenu des bases chargées est disponible dans       #
# le dossier 'doc'.                                                     #
#                                                                       #
# Résultat :                                                            #
#     - un tableau nommé 'temperature' avec les relevés de température  #
#     toutes stations confondues                                        #
#     - un tableau nommé 'temperature_station_active' avec les relevés  #
#      de température des stations actives                              #
#     - un tableau nommé 'precipitation' avec les relevés des           #
#     précipitations toutes stations confondues                         #
#     - un tableau nommé 'précipitation_station_active' avec les        #
#     relevés des précipitations des stations actives                   #
#     - un tableau nommé 'station_meteo' la liste des stations actives  #
#     et inactives présentent sur le département                        #
#########################################################################


#################### Initialisation variable  : choix du département

sel_dep <- "52"

#################### chargement des librairies

source("script/librairie.R")

#################### Suppression des fichiers gitkeep

source("script/suppression_gitkeep.R")

#################### Téléchargement et mise en forme des données météos

source("script/donnees_meteo.R")
