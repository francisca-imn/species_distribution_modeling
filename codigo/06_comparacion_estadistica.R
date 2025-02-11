library(caret)

# visualizar diferencias entre modelos --------------------------------------------
diff_future <- pred_recortado_future - arclim_recortado_future
diff_present_recortado <- pred_recortado - arclim_recortado

# Crear una paleta de colores para resaltar diferencias
diff_palette <- colorRampPalette(c("blue", "white", "red"))  # Azul (-), Blanco (0), Rojo (+)

# Graficar diferencias espaciales
png("reportes/diff_binarios_A-atacamensis.png", width = 1200, height = 600, res = 150)  # Ajustar tamaño y resolución
par(mfcol = c(1,2))

plot(diff_present_recortado, main = "Diferencia DISMO - ARCLIM \n(1980-2010)",
     cex.main = 0.85,
     col = diff_palette(100))

plot(diff_future, main = "Diferencia DISMO - ARCLIM \n(2035-2065)",
     cex.main = 0.85,
     col = diff_palette(100))
dev.off()

# Correlación ---------------------------------------------------------------------

# Extraer valores de las capas
values_future_dismo <- values(pred_recortado_future)
values_future_arclim <- values(arclim_recortado_future)

values_present_dismo <- values(pred_recortado)
values_present_arclim <- values(arclim_recortado)

# Calcular correlaciones
cor_future <- cor(values_future_dismo, values_future_arclim, use = "complete.obs")
cor_present <- cor(values_present_dismo, values_present_arclim, use = "complete.obs")

# Mostrar resultados
print(paste("Correlación DISMO vs ARCLIM (1980-2010):", round(cor_present, 3)))
print(paste("Correlación DISMO vs ARCLIM (2035-2065):", round(cor_future, 3)))


# Matriz confusion future -------------------------------------------------
# 1. Binarizar los mapas usando un umbral de 0.5 (ajústalo si es necesario)
#pred_future_bin <- pred_future_resampled > 0.5
#arclim_future_bin <- arclim_future > 0.5

# 2. Convertir los mapas binarizados a vectores
pred_values_future <- values(pred_recortado_future)
arclim_values_future <- values(arclim_recortado_future)

# 3. Remover valores NA para evitar problemas en la comparación
valid_indices_future <- !is.na(pred_values_future) & !is.na(arclim_values_future)
pred_values_future <- pred_values_future[valid_indices_future]
arclim_values_future <- arclim_values_future[valid_indices_future]

# 4. Crear la tabla cruzada (Matriz de Confusión)
confusion_matrix_future <- table(pred_values_future, arclim_values_future)
saveRDS(confusion_matrix_future, "reportes/confusion_matrix_future.rds")

# Mostrar la matriz de confusión
print(confusion_matrix_future)

# 5. Calcular el índice de Kappa usando caret
conf_matrix_future <- confusionMatrix(confusion_matrix_future)

# Mostrar el índice de Kappa
print(conf_matrix_future$overall["Kappa"])


# matriz confusion actual -------------------------------------------------------

# 1. Binarizar los mapas usando un umbral de 0.5 (ajústalo si es necesario)
#pred_future_bin <- pred_future_resampled > 0.5
#arclim_future_bin <- arclim_future > 0.5

# 2. Convertir los mapas binarizados a vectores
pred_values <- values(pred_recortado)
arclim_values <- values(arclim_recortado)

# 3. Remover valores NA para evitar problemas en la comparación
valid_indices <- !is.na(pred_values) & !is.na(arclim_values)
pred_values <- pred_values[valid_indices]
arclim_values <- arclim_values[valid_indices]

# 4. Crear la tabla cruzada (Matriz de Confusión)
confusion_matrix <- table(pred_values, arclim_values)

# Mostrar la matriz de confusión
saveRDS(confusion_matrix, "reportes/confusion_matrix_historico.rds")
print(confusion_matrix)

# 5. Calcular el índice de Kappa usando caret
conf_matrix <- confusionMatrix(confusion_matrix)

# Mostrar el índice de Kappa
print(conf_matrix$overall["Kappa"])


# histograma de diferencias -----------------------------------------------
#no me gustó!!

par(mfcol = c(1,2))

# Contar la frecuencia de cada categoría en los datos presentes
diff_present_values <- values(diff_present_recortado)
diff_present_freq <- table(factor(diff_present_values, levels = c(-1, 0, 1)))  # Asegura que -1, 0 y 1 aparezcan siempre

# Contar la frecuencia de cada categoría en los datos futuros
diff_future_values <- values(diff_future)
diff_future_freq <- table(factor(diff_future_values, levels = c(-1, 0, 1)))  # Asegura que -1, 0 y 1 aparezcan siempre

# Graficar el gráfico de barras para los datos presentes
barplot(diff_present_freq, main = "Diferencia DISMO - ARCLIM (1980-2010)",
        xlab = "Diferencia de probabilidad", ylab = "Frecuencia",
        col = "blue", names.arg = c("-1", "0", "1"))

# Graficar el gráfico de barras para los datos futuros
barplot(diff_future_freq, main = "Diferencia DISMO - ARCLIM (2035-2065)",
        xlab = "Diferencia de probabilidad", ylab = "Frecuencia",
        col = "blue", names.arg = c("-1", "0", "1"))
