# 🔍 Verificación: Archivos en el Target

## Verificación Rápida en Xcode

Sigue estos pasos para verificar si los archivos están en el target:

### 1. Abre el Proyecto en Xcode
- Abre `Tito.xcodeproj`

### 2. Verifica Build Phases

1. Selecciona el proyecto "Tito" (ícono azul en la parte superior del navegador)
2. Selecciona el target "Tito" (debajo de "TARGETS")
3. Ve a la pestaña **"Build Phases"**
4. Expande **"Compile Sources"**

### 3. Deberías Ver Esta Lista (21 archivos):

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

### 4. Si Faltan Archivos

**Solución Rápida:**

1. En el navegador izquierdo de Xcode, busca las carpetas:
   - `Models`
   - `Services`
   - `ViewModels`
   - `Views`

2. Si NO las ves en el navegador:
   - Arrástralas desde Finder (`/Users/raul/Downloads/Tito/Tito/`)
   - Asegúrate de marcar el target "Tito"

3. Si las ves pero tienen un ⚠️ o no están en "Compile Sources":
   - Selecciona cada archivo individualmente
   - Panel derecho > File Inspector > Target Membership
   - Marca "Tito"

---

## 🎯 Método Alternativo: Verificar Target Membership Individual

Si los archivos están en el navegador pero aún dan error:

1. Selecciona `OnboardingViewModel.swift` en el navegador
2. Panel derecho > **File Inspector** (primer ícono, parece un documento)
3. Busca **"Target Membership"**
4. Debe estar marcado **"Tito"**
5. Si no está marcado, márcalo

Repite para:
- `PreviewView.swift`
- `OnboardingView.swift`
- `KeychainService.swift`
- Y cualquier otro archivo que dé error

---

## ✅ Después de Agregar los Archivos

1. **Limpia el build**: Product > Clean Build Folder (⇧⌘K)
2. **Compila**: Presiona ⌘B
3. Los errores deberían desaparecer
4. **Ejecuta**: Presiona ⌘R

---

## 📝 Nota Importante

El código de `ContentView.swift` está **correcto**. El problema es solo que Xcode no está compilando los otros archivos porque no están en el target.

Una vez que agregues los archivos al target correctamente, todo debería funcionar.
