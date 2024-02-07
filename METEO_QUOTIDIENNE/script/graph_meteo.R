#################### Graphique des températures et précipitations
# POUR UNE STATION

# Initialisation variable
num_station <- NA

# Choix dela staion
while(is.na(num_station))
{
  # Création de la liste des stations
  list_station <- station_meteo %>%
                  mutate(id = paste(num_poste, nom_usuel, sep = "-")) %>%
                  filter(statut == "active") %>%
                  select(id,num_poste)
  
  # Afficher une boîte de dialogue pour choisir la station
  n_station <- dlg_list(list_station$id, multiple = FALSE, preselect = NULL, title = "Choisir la station ")$res

  # Récupération du numéro de la station
  num_station <- list_station %>%
                 filter(id == n_station) %>%
                 select(num_poste)
  
  num_station <- num_station$num_poste
}


# Préparation graph température
releve_meteo_temp <- meteo_temp %>%
                     filter(num_poste == num_station) %>%
                     # Passage de colonne en ligne
                     pivot_longer(c(tn, tm, tx),
                                  names_to = "mesure", 
                                  values_to = "temp") %>%
                     mutate(mesure = factor(mesure, levels = c("tx", "tm", "tn")))

# Préparation pluie
releve_meteo_pluie <- meteo_pluie %>%
                      filter(num_poste == num_station) %>%
                      # Passage de colonne en ligne
                      pivot_longer(c(rr),
                                   names_to = "mesure", 
                                   values_to = "mm") %>%
                      mutate(mesure = factor(mesure, levels = c("rr")))

nom_station <- releve_meteo_temp$nom_usuel[1]

# Construction du graphique des températures
graph_temp <- releve_meteo_temp %>%
             # Construction du graphique
             ggplot(aes(aaaammjj, temp, color = mesure)) +
                geom_point(size = 1, alpha = 0.01) +
                geom_smooth(method = "gam", 
                            formula = y ~ s(x, bs = "cs", k = 30)) +
            # Gestion de l'echelle des x (à modifier si besoin)
            scale_x_date(date_breaks = "3 years", 
                         date_labels = "%Y",
                         expand = c(0,0)) +
            scale_y_continuous(breaks = scales::breaks_pretty(4),
                               minor_breaks = scales::breaks_pretty(40)) +
            scale_color_manual(values = c("tn" = "deepskyblue2",
                                          "tm" = "grey50",
                                          "tx" = "firebrick2"),
                               labels = list("tx" = "T max", 
                                             "tm"= "T moyenne",
                                             "tn"= "T min")) +
            labs(subtitle = paste(nom_station, num_station, sep =" - "),
                 title =  paste("Evolution des températures quotidiennes : ",
                                paste(min(year(releve_meteo_temp$aaaammjj)), max(year(releve_meteo_temp$aaaammjj)), sep =" à "),
                                sep = ""),
                 colour = "Tendance",
                 caption =  paste("Données Météo-France : https://meteo.data.gouv.fr/", Sys.Date(), sep = "\n")) +
            theme_minimal() +
            theme(plot.caption = element_text(size = 6),
                  axis.title = element_blank())

# Affichage du graph des températures
graph_temp

# Construction du graphique des températures
graph_pluie <- releve_meteo_pluie %>%
               # Construction du graphique
               ggplot(aes(aaaammjj, mm, color = mesure)) +
               geom_point(size = 1, alpha = 0.01) +
               geom_smooth(method = "gam", 
                           formula = y ~ s(x, bs = "cs", k = 30)) +
               # Gestion de l'echelle des x (à modifier si besoin)
               scale_x_date(date_breaks = "3 years", 
                            date_labels = "%Y",
                            expand = c(0,0)) +
               scale_y_continuous(expand = c(0,0)) +
               scale_color_manual(values = c("rr" = "deepskyblue2"),
                                  labels = list("rr" = "en mm")) +
               labs(subtitle = paste(nom_station, num_station, sep =" - "),
                    title = paste("Evolution des précipitations quotidiennes de ",
                                  paste(min(year(releve_meteo_pluie$aaaammjj)), max(year(releve_meteo_pluie$aaaammjj)), sep =" à "),
                                  sep = ""),
                    colour = "Tendance",
                    caption =  paste("Données Météo-France : https://meteo.data.gouv.fr/", Sys.Date(), sep = "\n")) +
               theme_minimal() +
               theme(plot.caption = element_text(size = 6),
                    axis.title = element_blank())

# Affichage du graph des températures
graph_pluie
                           