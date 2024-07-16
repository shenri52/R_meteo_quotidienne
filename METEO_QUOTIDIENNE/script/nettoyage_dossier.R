#################### Nettoyage des dossiers

setwd("data/")
liste_fic <- list.files(pattern = "csv$")
file.remove(liste_fic)
setwd("..")

setwd("result/")
liste_fic <- list.files(pattern = "csv$")
file.remove(liste_fic)
setwd("..")

remove(liste_fic)