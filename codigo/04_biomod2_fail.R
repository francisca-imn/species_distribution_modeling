install.packages("biomod2")
library(biomod2)

install.packages(c("mda", "gam", "earth", "maxnet", "randomForest", "xgboost")) # Instalar los paquetes faltantes
update.packages(ask = FALSE) # Asegúrate de que los paquetes gbm y nlme estén actualizados para tu versión de R

# Preparar los datos para biomod2 con pseudo-ausencias
formatted_data <- BIOMOD_FormatingData(
  resp.var = rep(1, nrow(presence)),  # Todas las filas son presencias (1)
  expl.var = env_layers_actual,       # Capas ambientales actuales
  resp.xy = presence[, c("Longitud", "Latitud")], # Coordenadas
  resp.name = "MySpecies",            # Nombre de la especie o proyecto
  PA.nb.rep = 3,                      # Número de replicaciones de pseudo-ausencias
  PA.nb.absences = 1000,              # Número de pseudo-ausencias a generar
  PA.strategy = "random"              # Estrategia para generar pseudo-ausencias
)

print(formatted_data)

# Ejecutar el modelado sin opciones explícitas
biomod_model <- BIOMOD_Modeling(
  data = formatted_data,                  # Datos formateados
  models = c("GLM", "RF", "MAXENT.Phillips"), # Algoritmos a usar
  NbRunEval = 3,                          # Número de replicaciones
  DataSplit = 80,                         # Porcentaje de datos para entrenamiento
  VarImport = 3,                          # Importancia de las variables
  models.eval.meth = c("TSS", "ROC"),     # Métricas de evaluación
  SaveObj = TRUE,                         # Guardar objetos intermedios
  rescal.all.models = TRUE,               # Reescalar valores predichos
  do.full.models = FALSE                  # No entrenar modelos con todos los datos
)

