########## Carte des stations actives et inactives

station_meteo_shape <- station_meteo %>%
                       # Conversion du tableau en shape
                       st_as_sf(coords = c("lon", "lat"), crs = "EPSG:4326") %>%
                       st_transform(2154)

# Carte des données

# Chargement de la couche du département
dep_sig <- st_read("R:/BDCARTO/ADMINISTRATIF/DEPARTEMENT.shp") %>%
           filter(INSEE_DEP %in% sel_dep) %>%
           st_transform(2154)

# Construction de la carte
c_station <- ggplot(station_meteo_shape) +
             geom_sf(data = dep_sig,
                     alpha = 0) +
             geom_sf(aes(color = statut, shape = statut),
                     size = 2,
                     alpha = 0.5) +
             # Couleurs des points
             scale_color_manual(values = c("inactive" = "chocolate4", "active" = "chartreuse3")) +
             # Type de point (16 = rond plein, 17 = triangle plein)
             scale_shape_manual(values = c("inactive" = 16, "active" = 17)) +
             # Habillage de la carte
             labs(title = paste("Stations météo sur la période : ",
                          paste(min(year(meteo$aaaammjj)), max(year(meteo$aaaammjj)), sep =" - "),
                          sep = ""),
                 subtitle = "Haute-Marne",
                 caption =  paste("Données Météo-France : https://meteo.data.gouv.fr/", Sys.Date(), sep = "\n")) +
             theme_minimal()+
             theme(plot.caption = element_text(size = 6),
                   panel.grid =element_blank(),
                   axis.text = element_blank())

# Affichage de la carte
c_station
