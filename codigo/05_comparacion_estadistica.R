library(terra)
library(caret)

# visualizar diferencias entre modelos ------------------------------------
diff_future <- pred_future_resampled - arclim_future
diff_present <- pred_present_resampled - arclim_present

# Crear una paleta de colores para resaltar diferencias
diff_palette <- colorRampPalette(c("blue", "white", "red"))  # Azul (-), Blanco (0), Rojo (+)

# Graficar diferencias espaciales
par(mfcol = c(1,2))

plot(diff_present, main = "Diferencia DISMO - ARCLIM \n(1980-2010)",
     xlim = c(-77, -66), ylim = c(-56, -17), asp=1,
     cex.main = 0.85,
     col = diff_palette(100))

plot(diff_future, main = "Diferencia DISMO - ARCLIM \n(2035-2065)",
     xlim = c(-77, -66), ylim = c(-56, -17), asp=1,
     cex.main = 0.85,
     col = diff_palette(100))


# Correlación -------------------------------------------------------------

# Extraer valores de las capas
values_future_dismo <- values(pred_future_resampled)
values_future_arclim <- values(arclim_future)

values_present_dismo <- values(pred_present_resampled)
values_present_arclim <- values(arclim_present)

# Calcular correlaciones
cor_future <- cor(values_future_dismo, values_future_arclim, use = "complete.obs")
cor_present <- cor(values_present_dismo, values_present_arclim, use = "complete.obs")

# Mostrar resultados
print(paste("Correlación DISMO vs ARCLIM (1980-2010):", round(cor_present, 3)))
print(paste("Correlación DISMO vs ARCLIM (2035-2065):", round(cor_future, 3)))


# Matriz confusion future -------------------------------------------------
# 1. Binarizar los mapas usando un umbral de 0.5 (ajústalo si es necesario)
pred_future_bin <- pred_future_resampled > 0.5
arclim_future_bin <- arclim_future > 0.5

# 2. Convertir los mapas binarizados a vectores
pred_values <- values(pred_future_bin)
arclim_values <- values(arclim_future_bin)

# 3. Remover valores NA para evitar problemas en la comparación
valid_indices <- !is.na(pred_values) & !is.na(arclim_values)
pred_values <- pred_values[valid_indices]
arclim_values <- arclim_values[valid_indices]

# 4. Crear la tabla cruzada (Matriz de Confusión)
confusion_matrix <- table(pred_values, arclim_values)

# Mostrar la matriz de confusión
print(confusion_matrix)

# 5. Calcular el índice de Kappa usando caret
conf_matrix <- confusionMatrix(confusion_matrix)

# Mostrar el índice de Kappa
print(conf_matrix$overall["Kappa"])


# matriz confusion actual -------------------------------------------------

# 📌 1. Binarizar los mapas presentes
pred_present_bin <- pred_present_resampled > 0.5
arclim_present_bin <- arclim_present > 0.5

# 📌 2. Convertir los mapas binarizados a vectores
pred_present_values <- values(pred_present_bin)
arclim_present_values <- values(arclim_present_bin)

# 📌 3. Remover valores NA para evitar problemas en la comparación
valid_indices_present <- !is.na(pred_present_values) & !is.na(arclim_present_values)
pred_present_values <- pred_present_values[valid_indices_present]
arclim_present_values <- arclim_present_values[valid_indices_present]

# 📌 4. Crear la tabla cruzada (Matriz de Confusión)
confusion_matrix_present <- table(pred_present_values, arclim_present_values)

# 📌 5. Calcular el índice de Kappa usando caret
conf_matrix_present <- confusionMatrix(confusion_matrix_present)

# 📌 6. Mostrar resultados
print(confusion_matrix_present)
print(conf_matrix_present$overall["Kappa"])


# histograma de diferencias -----------------------------------------------
#no me gustó!!

par(mfcol = c(1,2))

hist(values(diff_present), breaks = 50, main = "Diferencia DISMO - ARCLIM \n(1980-2010)",
     xlab = "Diferencia de probabilidad", col = "blue")

hist(values(diff_future), breaks = 50, main = "Diferencia DISMO - ARCLIM \n(1980-2010)",
     xlab = "Diferencia de probabilidad", col = "blue")
