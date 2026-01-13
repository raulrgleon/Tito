# Solución: Target Vacío en Xcode

El error "target 'Tito' referenced in product 'Tito' is empty" ocurre porque los archivos Swift no están agregados al target de compilación.

## Solución Rápida (Recomendada)

### Opción 1: Agregar archivos manualmente en Xcode

1. Abre `Tito.xcodeproj` en Xcode
2. En el navegador de proyectos (panel izquierdo), haz clic derecho en la carpeta "Tito"
3. Selecciona "Add Files to Tito..."
4. Selecciona TODAS las carpetas y archivos:
   - `Models/` (todos los archivos dentro)
   - `Services/` (todos los archivos dentro)
   - `ViewModels/` (todos los archivos dentro)
   - `Views/` (todos los archivos dentro)
5. Asegúrate de que:
   - ✅ "Copy items if needed" esté DESACTIVADO
   - ✅ "Create groups" esté seleccionado
   - ✅ El target "Tito" esté marcado
6. Haz clic en "Add"

### Opción 2: Arrastrar y soltar

1. Abre `Tito.xcodeproj` en Xcode
2. Abre Finder y navega a la carpeta `Tito/`
3. Arrastra las carpetas `Models`, `Services`, `ViewModels`, y `Views` al proyecto en Xcode
4. Cuando aparezca el diálogo:
   - ✅ Marca "Copy items if needed" como DESACTIVADO
   - ✅ Selecciona "Create groups"
   - ✅ Asegúrate de que el target "Tito" esté marcado
5. Haz clic en "Finish"

## Verificación

Después de agregar los archivos:

1. En Xcode, selecciona el proyecto "Tito" en el navegador
2. Selecciona el target "Tito"
3. Ve a la pestaña "Build Phases"
4. Expande "Compile Sources"
5. Deberías ver todos los archivos `.swift` listados (alrededor de 20 archivos)

## Si el problema persiste

1. Cierra Xcode completamente
2. Elimina los archivos derivados:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/Tito-*
   ```
3. Abre Xcode nuevamente
4. Product > Clean Build Folder (⇧⌘K)
5. Intenta compilar nuevamente (⌘B)

## Archivos que deben estar en el target

Asegúrate de que estos archivos estén incluidos:

### Models (4 archivos)
- Preset.swift
- StreamConfig.swift
- StreamState.swift
- Telemetry.swift

### Services (6 archivos)
- AudioService.swift
- CameraService.swift
- EncoderService.swift
- KeychainService.swift
- NetworkMonitor.swift
- RTMPService.swift

### ViewModels (3 archivos)
- OnboardingViewModel.swift
- SettingsViewModel.swift
- StreamViewModel.swift

### Views (6 archivos)
- ConnectView.swift
- DiagnosticsView.swift
- EndView.swift
- LiveView.swift
- OnboardingView.swift
- PreviewView.swift

### Root (2 archivos)
- TitoApp.swift
- ContentView.swift

**Total: 21 archivos Swift**
