#################### Téléchargementdes données météos

# Compter le nombre de fichiers météo france disponible sur data.gouv.fr
n_files <- GET("https://www.data.gouv.fr/api/2/datasets/6569b51ae64326786e4e8e1a/") %>%
           content() %>%
           pluck("resources", "total")

# Lire les informations des fichiers disponible
files_available <- GET(paste("https://www.data.gouv.fr/api/2/datasets/6569b51ae64326786e4e8e1a/resources/?page=1&page_size=",
                             n_files, sep ="")) %>%  
                   content(as = "text", encoding = "UTF-8") %>%
                   fromJSON(flatten = TRUE) %>%
                   pluck("data") %>%
                   as_tibble(.name_repair = make_clean_names) %>%
                   # Filtre département et du type d'observation (RR = RR-T-Vent)
                   filter(str_detect(title, "RR-T-Vent"))
                          
# Choix du département
donnees_dispo <- NULL

  # Construction de la liste des départements disponibles
sel_dep <- files_available$title %>%
           str_extract("\\d+") %>%
           na.omit() %>%
           unique()

  # Affichage de la boîte de dialogue de choix du département
while (is_empty(donnees_dispo))
{
  
  donnees_dispo <- dlg_list(sel_dep,
                            multiple = FALSE,
                            title = "Choix du département")$res
  
}

donnees_dispo <- paste("departement_", donnees_dispo, sep ="")

  # Filtre des fichiers de données
files_available <- files_available %>%
                   filter(str_detect(title, donnees_dispo))

# Choix des données à télécharger
donnees_dispo <- NULL

  # Affichage de la boîte de dialogue de choix des données
while (is_empty(donnees_dispo))
{
  donnees_dispo <- dlg_list(files_available$description,
                            multiple = TRUE,
                            title = "Quels données voulez vous télécharger ? Choix multiple possible")$res
}
  
  # Filtre des données
files_available <- files_available %>%
                   filter(description %in%  c(donnees_dispo))

# Téléchargement des données
for (i in 1:nrow(files_available))
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

rm(list = ls())
gc()