#!/bin/bash
# Script para crear estructura de proyecto Xcode completa

# Este script necesita ejecutarse desde Xcode o usar xcodegen si está disponible
# Por ahora, vamos a crear los archivos de assets necesarios

mkdir -p "Tito/Preview Content"
mkdir -p "Tito/Assets.xcassets/AppIcon.appiconset"
mkdir -p "Tito/Assets.xcassets/AccentColor.colorset"

echo "Estructura de carpetas creada. Ahora necesitas abrir el proyecto en Xcode y agregar los archivos manualmente."
