library(rgbif)
library(tidyverse)
library(httr)
library(rnaturalearth)
library(rnaturalearthdata)
library(rJava)

# Obteniendo data de GBIF -------------------------------------------------
especie_info <- name_backbone(name = "Adesmia atacamensis")  #cambiar el nombre por el de la especie de interés

especie_data <- occ_search(taxonKey = especie_info$usageKey,                         
                           country = "CL",                    #solo datos de Chile
                           hasCoordinate = TRUE,              #solo registros con coordenadas
                           hasGeospatialIssue = FALSE,
                           limit = 5000)        #sin problemas espaciales
                        
data_ocurrencias <- especie_data$data

# en base a observaciones -------------------------------------------------
data_ocurrencias_filtered <- data_ocurrencias %>%
  filter(basisOfRecord %in% c("HUMAN_OBSERVATION", "MACHINE_OBSERVATION"))

# Eliminar datos de iNaturalist.org ---------------------------------------
data_ocurrencias_filtered <- data_ocurrencias_filtered %>%
  filter(publishingOrgKey != "28eb1a3f-1c15-4a95-931a-4af90ecb574d")  #esto es equivalente a references, reemplazar por los códigos que no son fuentes confiables

# Precisión espacial adecuada ---------------------------------------------
data_ocurrencias_filtered <- data_ocurrencias_filtered %>%
  filter(coordinateUncertaintyInMeters <= 1000 | is.na(coordinateUncertaintyInMeters))  # Incertidumbre < 1 km

# cautiverio o zoo --------------------------------------------------------
data_ocurrencias_filtered <- data_ocurrencias_filtered %>%
  filter(!grepl("zoo|captive|rescue", locality, ignore.case = TRUE))

# calidad taxonómica ------------------------------------------------------
data_ocurrencias_filtered <- data_ocurrencias_filtered %>%
  filter(taxonRank == "SPECIES", taxonomicStatus == "ACCEPTED")

# evitar duplicados -------------------------------------------------------
data_ocurrencias_filtered <- data_ocurrencias_filtered %>%
  distinct(decimalLongitude, decimalLatitude, year, .keep_all = TRUE)

# 📊 Resultados y visualización -------------------------------------------
print(paste("Registros originales:", nrow(data_ocurrencias)))
print(paste("Registros filtrados:", nrow(data_ocurrencias_filtered)))

# 📌 Mantener solo las columnas de coordenadas ----------------------------
data_ocurrencias_filtered <- data_ocurrencias_filtered %>%
  select(decimalLongitude, decimalLatitude)




# Esto no lo uso mucho porque data=0 --------------------------------------
#unique(data_ocurrencias$issues)
#data_ocurrencias_filtered <- data_ocurrencias %>%  #OJO, ESTO ELIMINA TODOS LOS DATOS
#  filter(issues == "")  # Solo registros sin problemas reportados


# sobre instituciones de origen -------------------------------------------
#unique(data_ocurrencias$publishingOrgKey)

# Función para obtener el nombre de la organización por su publishingOrgKey:
#get_org_name <- function(org_key) {              
#  url <- paste0("https://api.gbif.org/v1/organization/", org_key)
#  response <- fromJSON(content(GET(url), "text"), flatten = TRUE)
#  return(response$title)
#}

# Aplicar la función a los códigos únicos en los datos:
#org_names <- unique(data_ocurrencias$publishingOrgKey)
#org_info <- sapply(org_names, get_org_name)

# Ver los resultados y analizar si alguno no corresponde:
#print(org_info)


# Fecha (actuales) --------------------------------------------------------
# esto no porque el modelo actual abarca hartos años:
#data_ocurrencias_filtered <- data_ocurrencias_filtered %>%  
#  filter(year >= 2023)  

