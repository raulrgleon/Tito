# 🔧 Solución Definitiva: Agregar Archivos al Target en Xcode

El error "target 'Tito' referenced in product 'Tito' is empty" significa que los archivos Swift no están en el target de compilación.

## ✅ Solución Rápida (2 minutos)

### Método 1: Arrastrar y Soltar (MÁS FÁCIL)

1. **Cierra Xcode** si está abierto

2. **Abre Finder** y navega a:
   ```
   /Users/raul/Downloads/Tito/Tito/
   ```

3. **Abre Xcode** y abre el proyecto `Tito.xcodeproj`

4. En el **navegador izquierdo de Xcode**, verás la carpeta "Tito"

5. **Arrastra desde Finder** estas 4 carpetas al proyecto en Xcode:
   - `Models` (arrastra la carpeta completa)
   - `Services` (arrastra la carpeta completa)
   - `ViewModels` (arrastra la carpeta completa)
   - `Views` (arrastra la carpeta completa)

6. Cuando aparezca el diálogo **"Choose options for adding these files"**:
   - ✅ **DESMARCA** "Copy items if needed" (NO copiar)
   - ✅ **SELECCIONA** "Create groups" (no "Create folder references")
   - ✅ **MARCA** el target "Tito"
   - Haz clic en **"Finish"**

7. **Verifica**:
   - Selecciona el proyecto "Tito" en el navegador
   - Selecciona el target "Tito"
   - Ve a "Build Phases" > "Compile Sources"
   - Deberías ver ~21 archivos Swift listados

8. **Compila**: Presiona ⌘B

9. **Ejecuta**: Presiona ⌘R

---

### Método 2: Add Files to Tito (ALTERNATIVA)

1. En Xcode, haz **clic derecho** en la carpeta "Tito" en el navegador izquierdo

2. Selecciona **"Add Files to Tito..."**

3. En el diálogo:
   - Navega a `/Users/raul/Downloads/Tito/Tito/`
   - **Selecciona** las carpetas: `Models`, `Services`, `ViewModels`, `Views`
   - ✅ **DESMARCA** "Copy items if needed"
   - ✅ **SELECCIONA** "Create groups"
   - ✅ **MARCA** el target "Tito"
   - Haz clic en **"Add"**

---

## 🔍 Verificación Final

Después de agregar los archivos:

1. Selecciona el proyecto "Tito" (ícono azul en la parte superior del navegador)
2. Selecciona el target "Tito" debajo de "TARGETS"
3. Ve a la pestaña **"Build Phases"**
4. Expande **"Compile Sources"**
5. Deberías ver esta lista (21 archivos):

```
✅ TitoApp.swift
✅ ContentView.swift
✅ Models/Preset.swift
✅ Models/StreamConfig.swift
✅ Models/StreamState.swift
✅ Models/Telemetry.swift
✅ Services/AudioService.swift
✅ Services/CameraService.swift
✅ Services/EncoderService.swift
✅ Services/KeychainService.swift
✅ Services/NetworkMonitor.swift
✅ Services/RTMPService.swift
✅ ViewModels/OnboardingViewModel.swift
✅ ViewModels/SettingsViewModel.swift
✅ ViewModels/StreamViewModel.swift
✅ Views/ConnectView.swift
✅ Views/DiagnosticsView.swift
✅ Views/EndView.swift
✅ Views/LiveView.swift
✅ Views/OnboardingView.swift
✅ Views/PreviewView.swift
```

---

## ⚠️ Si Aún No Funciona

### Verificar Target Membership de Cada Archivo

1. Selecciona **cada archivo .swift** individualmente en el navegador
2. En el panel derecho, ve a **"File Inspector"** (primer ícono)
3. En **"Target Membership"**, asegúrate de que **"Tito"** esté marcado
4. Repite para todos los archivos

### Limpiar y Recompilar

1. **Product > Clean Build Folder** (⇧⌘K)
2. Cierra Xcode
3. Elimina DerivedData:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/Tito-*
   ```
4. Abre Xcode nuevamente
5. Compila (⌘B)

---

## 📝 Nota Importante

Si después de agregar los archivos ves errores de compilación como "No such module 'HaishinKit'", necesitas agregar la dependencia:

1. **File > Add Package Dependencies...**
2. URL: `https://github.com/shogo4405/HaishinKit.swift.git`
3. Versión: `1.5.0` o superior
4. Target: "Tito"
5. Haz clic en "Add Package"

---

## ✅ Listo

Una vez que todos los archivos estén en el target y compiles sin errores, podrás ejecutar la app con ⌘R.
