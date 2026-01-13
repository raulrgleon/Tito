# Instrucciones de Compilación - Tito

## Requisitos Previos

1. **Xcode 15.0 o superior**
   - Descarga desde el Mac App Store
   - Asegúrate de tener las herramientas de línea de comandos instaladas

2. **iOS 16.0+ SDK**
   - Se instala automáticamente con Xcode

3. **Dispositivo iPhone físico** (recomendado)
   - La app requiere acceso a la cámara y micrófono
   - El simulador tiene limitaciones para streaming en vivo

## Pasos de Compilación

### 1. Abrir el Proyecto

```bash
cd /Users/raul/Downloads/Tito
open Tito.xcodeproj
```

### 2. Configurar el Equipo de Desarrollo

1. En Xcode, selecciona el proyecto "Tito" en el navegador
2. Ve a la pestaña "Signing & Capabilities"
3. Selecciona tu equipo de desarrollo de Apple
4. Xcode generará automáticamente un perfil de aprovisionamiento

### 3. Resolver Dependencias

Las dependencias se resolverán automáticamente cuando compiles por primera vez. Si necesitas hacerlo manualmente:

1. En Xcode, ve a **File > Packages > Reset Package Caches**
2. Luego **File > Packages > Update to Latest Package Versions**

La dependencia principal es:
- **HaishinKit** (https://github.com/shogo4405/HaishinKit.swift.git)

### 4. Seleccionar el Dispositivo

1. En la barra de herramientas superior, selecciona tu iPhone físico
2. Asegúrate de que el dispositivo esté conectado y confiado

### 5. Compilar y Ejecutar

1. Presiona **⌘R** o haz clic en el botón "Run"
2. La primera compilación puede tardar varios minutos
3. Si aparece un error de firma, ajusta la configuración en "Signing & Capabilities"

## Solución de Problemas Comunes

### Error: "No such module 'HaishinKit'"

**Solución:**
1. Ve a **File > Packages > Reset Package Caches**
2. Cierra y vuelve a abrir Xcode
3. Compila nuevamente

### Error: "Signing for Tito requires a development team"

**Solución:**
1. Ve a **Tito > Signing & Capabilities**
2. Selecciona tu equipo de desarrollo
3. Si no tienes uno, crea una cuenta gratuita en developer.apple.com

### Error: "Camera permission denied"

**Solución:**
1. Ve a **Configuración > Tito** en tu iPhone
2. Activa los permisos de Cámara y Micrófono

### La app se cierra al iniciar

**Solución:**
1. Verifica que tengas un dispositivo físico seleccionado (no simulador)
2. Revisa los logs en Xcode Console (⌘⇧Y)
3. Asegúrate de que todos los permisos estén concedidos

## Estructura del Proyecto

```
Tito/
├── Tito/
│   ├── Models/          # Modelos de datos
│   ├── Services/        # Servicios (cámara, audio, RTMP, etc.)
│   ├── ViewModels/      # ViewModels MVVM
│   ├── Views/           # Vistas SwiftUI
│   ├── TitoApp.swift    # Punto de entrada
│   └── ContentView.swift
├── TitoTests/           # Tests unitarios
└── README.md
```

## Configuración de Restream

Antes de usar la app, necesitas:

1. Una cuenta de Restream (gratuita)
2. URL del servidor RTMP (ejemplo: `rtmp://live.restream.io/live`)
3. Tu clave de transmisión (stream key)

Ver el README.md para instrucciones detalladas.

## Notas Importantes

- **Primera ejecución**: La app solicitará permisos de cámara y micrófono
- **Testing**: Usa un dispositivo físico, no el simulador
- **Red**: Para mejores resultados, usa Wi-Fi estable
- **Batería**: El streaming consume mucha batería, mantén el dispositivo cargado

## Siguiente Paso

Una vez compilada la app:
1. Abre la app en tu iPhone
2. Completa el onboarding (si es la primera vez)
3. Configura tus credenciales de Restream
4. ¡Presiona "GO LIVE"!
