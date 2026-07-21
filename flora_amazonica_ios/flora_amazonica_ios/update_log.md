# Resumen de Correcciones Implementadas

## 1. Formularios dinámicos que no cargaban (Solo salía dasométricos)
Se identificó que el backend enviaba ciertos campos como `null` (por ejemplo, `is_required` o descripciones opcionales). La app de iOS era demasiado estricta al procesar el JSON, y al encontrar un `null` descartaba *todo* el formulario dinámico. Al descartarlo, solo mostraba los datos dasométricos (que están fijos en código para árboles).
**Solución:** Se flexibilizó el modelo de datos en Swift (`MorphologicalValueDTO`) para que acepte valores nulos de forma segura. Ahora carga correctamente todos los formularios dinámicos específicos para cada Hábito (Árbol, Palmera, Liana, etc.).

## 2. Registro "desaparecido" en el Consultor (Aparecía solo en "No estoy seguro")
Exactamente el mismo problema de mapeo estricto, pero aplicado a los registros validados de las especies (`SpeciesRecordDTO`). Al crear un "Árbol", algunos campos como `country_distribution` o `morphological_data` podían guardarse como nulos o en un formato que Swift rechazaba. Esto causaba un error silencioso que hacía que el registro se eliminara por completo de las listas del lado de iOS (por eso no salía en "Últimos registros" ni filtrando por "Árbol"). "No estoy seguro" no tiene campos dinámicos complejos, por lo que su JSON solía parsearse sin errores.
**Solución:** Se corrigió el mapeo de registros en `RealEspecieRepository` para que tolere campos vacíos. Todos los registros validados, sin importar su hábito, ahora aparecerán donde corresponden.

## 3. Fotos que no se enviaban al Validador
El backend tiene una regla estricta: solo acepta imágenes en formato JPEG/PNG y que pesen **menos de 10 MB**. En iOS, al seleccionar fotos directamente de la galería o de la cámara (ej: iPhone Pro de 48MP), los archivos suelen ser inmensos.
La solución inicial fue simplemente comprimir el archivo a JPEG (0.8), pero seguía generando JPEGs de > 10MB que el backend rechazaba en silencio.
**Solución Reforzada:** Se implementó el redimensionamiento de las fotos a un máximo de 1280px por lado, además de compresión. Esto asegura que la foto siempre pese menos de 1 MB, garantizando que suban rápido y lleguen al Validador.

## 4. Refresh para Formularios Dinámicos
**Solución:** Se integró el gesto de "jalar para recargar" (`.refreshable`) en la vista de Morfología. Si el administrador desactiva un campo desde la web, el registrador solo tiene que deslizar hacia abajo en la pantalla del formulario para obtener los campos actualizados al instante.
