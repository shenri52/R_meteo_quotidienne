#################### Mise en forme des données météos

# Création d'un dataframe avec les données téléchargées
meteo <- list.files("data", full.names = TRUE) %>%
         map(read.delim,
             sep = ";",
             colClasses = c("NUM_POSTE" = "character", "AAAAMMJJ" = "character")) %>%
         list_rbind() %>%
         as_tibble(.name_repair = make_clean_names) %>%
         # Suppression des espaces contenus dans le champs
         mutate(num_poste = str_trim(num_poste)) %>%
         # Conversion de la date
         mutate(aaaammjj = ymd(aaaammjj))

# Regroupement des station météo
station_meteo <- meteo %>%
                 summarise(.by= c(nom_usuel, num_poste, lat, lon),
                           # Ajout de la date de début des relevés
                           deb_fonc = min(year(aaaammjj)),
                           # Ajout de la date de fin
                           fin_fonc = max(year(aaaammjj))) %>%
                 # Contrôle de la dernière date de mesure pour définir le statut de la station
                 mutate(statut = ifelse(fin_fonc == year(Sys.Date()), 
                                        "active", 
                                        "inactive"))

# Choix d'une ou plusieurs dates

  # Afficher une boîte de dialogue pour indiquer le lecteur à analyser
choix_date <- NULL

while (is_empty(choix_date) || !(choix_date %in% c("oui", "non")))
{
  choix_date <- dlgInput("Voulez vous choisir une ou plusieurs dates précises ? (oui ou non)")$res
}

# Filtre des données sur les dates choisies
if(choix_date == "oui")
{
  # Choix de l'année
  donnees_dispo <- NULL
  
  while (is_empty(donnees_dispo))
  {
    donnees_dispo <- dlg_list(unique(year(meteo$aaaammjj)),
                              multiple = TRUE,
                              title = "Données météo quotidienne - Choix multiple possible")$res
  }
  
  meteo <- meteo %>%
           filter(year(meteo$aaaammjj) == donnees_dispo)
  
  #Choix du mois
  
  donnees_dispo <- NULL
  
  while (is_empty(donnees_dispo))
  {
    donnees_dispo <- dlg_list(unique(month(meteo$aaaammjj)),
                              multiple = TRUE,
                              title = "Données météo quotidienne - Choix multiple possible")$res
  }
  
  meteo <- meteo %>%
           filter(month(meteo$aaaammjj) == donnees_dispo)
  
  # Choix du ou des jour
  
  donnees_dispo <- NULL
  
  while (is_empty(donnees_dispo))
  {
    donnees_dispo <- dlg_list(unique(meteo$aaaammjj),
                              multiple = TRUE,
                              title = "Données météo quotidienne - Choix multiple possible")$res
  }
  
  meteo <- meteo %>%
           filter(aaaammjj %in% c(donnees_dispo))
  
}


# Relevés de températures pour les stations actives
meteo_temp <- meteo %>%
              # Filtre des stations sans température min
              filter(!(is.na(tn))) %>%
              # Filtre des stations sans température max
              filter(!(is.na(tx))) %>%               
              # Calcul de la température moyenne si absente
              mutate(tm = ifelse(is.na(tm), (tx + tn) / 2, tm)) %>%
              select(num_poste, nom_usuel, aaaammjj, tn, tm, tx) %>%
              rename.variable("tn", "Tmin") %>%
              rename.variable("tm", "Tmoy") %>%
              rename.variable("tx", "Tmax") %>%
              left_join(select(station_meteo, num_poste, statut),
                               by = c("num_poste" = "num_poste"),
                               copy = FALSE)

# Relevés des précipitations pour les stations actives
meteo_pluie <- meteo %>%
               # Filtre des stations météos sans précipitations
               filter(!(is.na(rr))) %>%
               select(num_poste, nom_usuel, aaaammjj, rr) %>%
               rename.variable("rr", "Pmm") %>%
               left_join(select(station_meteo, num_poste, statut),
                         by = c("num_poste" = "num_poste"),
                         copy = FALSE)

remove(meteo)

# Export des données
write.table(meteo_temp,
            file = paste("result/temperature.csv"),
            fileEncoding = "UTF-8",
            sep =";",
            row.names = FALSE)

write.table(meteo_pluie,
            file = paste("result/precipitation.csv"),
            fileEncoding = "UTF-8",
            sep =";",
            row.names = FALSE)

write.table(station_meteo,
            file = paste("result/station_meteo.csv"),
            fileEncoding = "UTF-8",
            sep =";",
            row.names = FALSE)

rm(list = ls())
gc()
