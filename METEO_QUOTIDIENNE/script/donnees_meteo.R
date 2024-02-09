#################### Téléchargement et mise en forme des données météos

# Compter le nombre de fichiers météo france disponible sur data.gouv.fr
n_files <- GET("https://www.data.gouv.fr/api/2/datasets/6569b51ae64326786e4e8e1a/") %>%
           content() %>%
           pluck("resources", "total")

# Lire les informations des fichiers disponible
files_available <- GET(paste("https://www.data.gouv.fr/api/2/datasets/6569b4473bedf2e7abad3b72/resources/?page=1&page_size=",
                             paste(n_files, "&type=main", sep =""),
                             sep = "")) %>%  
                   content(as = "text", encoding = "UTF-8") %>%
                   fromJSON(flatten = TRUE) %>%
                   pluck("data") %>%
                   as_tibble(.name_repair = make_clean_names) %>%
                   # Ajout du code département et du type d'observations
                   mutate(dep = str_sub(title, 18,19)) %>%
                   mutate(type_obs = str_sub(title, 39,40)) %>%
                   # Filtre département et du type d'observation (RR = RR-T-Vent)
                   filter(dep == sel_dep,
                          type_obs == "RR")

# Comptage du nombre de fichier
nb_fichier <- count(files_available)

# Téléchargement des fichiers
for (i in 1:nb_fichier$n)
    {
      
      # Initialisation d'une variable avec l'URL de téléchargement
      url <- as.character(files_available[i, 7]) 
      
      # Téléchargement du fichier
      GET(url,
          write_disk(paste("data/",
                     paste(files_available[i, 2], files_available[i, 6], sep = "."),
                     sep = ""),
                     overwrite = TRUE))
    }

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

# Création d'un dataframe avec les relevés de températures (toutes stations)
meteo_temp <- meteo %>%
              # Filtre des stations sans température min
              filter(!(is.na(tn))) %>%
              # Filtre des stations sans température max
              filter(!(is.na(tx))) %>%               
              # Calcul de la température moyenne si absente
              mutate(tm = ifelse(is.na(tm), (tx + tn) / 2, tm)) %>%
              select(num_poste, nom_usuel, aaaammjj, tn, tm, tx)

# Création d'un dataframe avec les relevés de précipitations (toutes stations)
meteo_pluie <- meteo %>%
               # Filtre des stations météos sans précipitations
               filter(!(is.na(rr))) %>%
               select(num_poste, nom_usuel, aaaammjj, rr)

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

# Relevés de températures pour les stations actives
meteo_temp_s_active <- meteo_temp %>%
                        left_join(select(station_meteo, num_poste, statut),
                                  by = c("num_poste" = "num_poste"),
                                  copy = FALSE) %>%
                          filter(statut == "active")

# Relevés des précipitations pour les stations actives
meteo_pluie_s_active <- meteo_pluie %>%
                        left_join(select(station_meteo, num_poste, statut),
                                  by = c("num_poste" = "num_poste"),
                                  copy = FALSE) %>%
                        filter(statut == "active")
# Export des données
write.table(meteo_temp,
            file = paste("result/temperature.csv"),
            fileEncoding = "UTF-8",
            sep =";",
            row.names = FALSE)

write.table(meteo_temp_s_active,
            file = paste("result/temperature_station_active.csv"),
            fileEncoding = "UTF-8",
            sep =";",
            row.names = FALSE)

write.table(meteo_pluie,
            file = paste("result/precipitation.csv"),
            fileEncoding = "UTF-8",
            sep =";",
            row.names = FALSE)

write.table(meteo_pluie_s_active,
            file = paste("result/precipitation_station_active.csv"),
            fileEncoding = "UTF-8",
            sep =";",
            row.names = FALSE)

write.table(station_meteo,
            file = paste("result/station_meteo.csv"),
            fileEncoding = "UTF-8",
            sep =";",
            row.names = FALSE)
