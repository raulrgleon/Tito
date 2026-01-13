# Tito - Streaming en Vivo desde iPhone

Tito es una aplicación iOS que permite transmitir video y audio en vivo desde tu iPhone directamente a Restream usando RTMP.

## Características

- ✅ Transmisión en vivo desde la cámara y micrófono del iPhone
- ✅ Conexión simple con Restream (solo URL y clave)
- ✅ Tres presets de calidad configurables
- ✅ Adaptación automática de bitrate según condiciones de red
- ✅ Reconexión automática con backoff exponencial
- ✅ Telemetría en tiempo real
- ✅ Interfaz minimalista y moderna
- ✅ Modo oscuro por defecto
- ✅ Sin paywalls ni funciones premium

## Requisitos

- iOS 16.0 o superior
- iPhone con cámara
- Cuenta de Restream con URL RTMP y clave de transmisión

## Instalación

### Opción 1: Xcode (Recomendado)

1. Abre `Tito.xcodeproj` en Xcode 15.0 o superior
2. Asegúrate de tener configurado tu equipo de desarrollo en Xcode
3. Selecciona tu dispositivo iPhone como destino
4. Presiona ⌘R para compilar y ejecutar

### Opción 2: Swift Package Manager

La aplicación usa HaishinKit como dependencia. Xcode debería descargarla automáticamente al abrir el proyecto.

Si necesitas agregarla manualmente:
1. En Xcode, ve a File > Add Package Dependencies
2. Ingresa: `https://github.com/shogo4405/HaishinKit.swift.git`
3. Selecciona la versión 1.5.0 o superior

## Configuración de Restream

### Obtener tus credenciales de Restream

1. Inicia sesión en tu cuenta de Restream
2. Ve a "Destinations" > "Add Destination" > "RTMP"
3. Copia la URL del servidor RTMP (ejemplo: `rtmp://live.restream.io/live`)
4. Copia tu clave de transmisión (stream key)

### Configurar en Tito

1. Abre la aplicación Tito
2. Si es la primera vez, verás la pantalla de onboarding
3. Toca "Conectar Restream"
4. Ingresa:
   - **Servidor**: Tu URL RTMP de Restream (ejemplo: `rtmp://live.restream.io/live`)
   - **Clave de Transmisión**: Tu stream key de Restream
5. Toca "Guardar"

**Alternativa - URL Completa:**
- Activa el toggle "Usar URL RTMP completa"
- Pega la URL completa: `rtmp://live.restream.io/live/TU_STREAM_KEY`

### Configuración Recomendada en Restream

Para obtener los mejores resultados:

1. **Formato de Video**: H.264
2. **Resolución**: 720p o 1080p (según el preset que uses)
3. **Frame Rate**: 30 fps o 60 fps
4. **Bitrate**: Ajusta según el preset:
   - Street: 2000-3000 kbps
   - Wi-Fi: 4500-6000 kbps
   - High Quality: 6500-9000 kbps

## Uso

### Pantalla de Vista Previa

- **Cambiar cámara**: Toca el ícono de rotación de cámara
- **Flash**: Toca el ícono de rayo (solo cámara trasera)
- **Micrófono**: Toca el ícono de micrófono para activar/desactivar
- **Preset**: Selecciona entre Street, Wi-Fi o High Quality
- **GO LIVE**: Inicia la transmisión

### Durante la Transmisión

- **Timer**: Muestra la duración de la transmisión
- **Estado de Red**: Indicador de color (verde/amarillo/rojo)
- **Telemetría**: Bitrate, frames perdidos, tamaño de cola
- **Cambiar cámara**: Disponible durante la transmisión
- **Finalizar**: Detiene la transmisión

### Pantalla de Diagnósticos

Para acceder a diagnósticos avanzados:
1. Toca 5 veces en el número de versión (v1.0) en la esquina superior
2. Verás métricas detalladas y estado del sistema

## Presets

### Street (Por defecto)
- **Resolución**: 1280x720 @ 30fps
- **Bitrate**: 2500 kbps (rango: 2000-3000)
- **Uso**: Optimizado para estabilidad en conexiones móviles

### Wi-Fi
- **Resolución**: 1920x1080 @ 30fps
- **Bitrate**: 5000 kbps (rango: 4500-6000)
- **Uso**: Calidad alta cuando estás en Wi-Fi estable

### High Quality
- **Resolución**: 1920x1080 @ 60fps
- **Bitrate**: 7500 kbps (rango: 6500-9000)
- **Uso**: Máxima calidad para conexiones excelentes

## Adaptación de Bitrate

Tito ajusta automáticamente el bitrate según:
- Estado de la conexión de red
- Frames perdidos
- Tamaño de la cola de envío

Si la conexión empeora, el bitrate se reduce gradualmente. Si mejora, aumenta hasta el máximo del preset.

## Reconexión Automática

Si la conexión se pierde:
1. Tito detecta la desconexión automáticamente
2. Intenta reconectar con backoff exponencial (2s, 4s, 8s, 16s, hasta 30s)
3. Máximo 10 intentos
4. Si falla, muestra un botón "Reintentar" en la UI

## Solución de Problemas

### La transmisión no inicia

1. Verifica que tengas conexión a internet
2. Confirma que las credenciales de Restream sean correctas
3. Asegúrate de que Restream acepte transmisiones RTMP
4. Revisa los permisos de cámara y micrófono en Configuración > Tito

### Calidad de video pobre

1. Verifica tu conexión de red (Wi-Fi recomendado)
2. Prueba con el preset "Street" primero
3. Revisa el indicador de estado de red en la app
4. Asegúrate de tener buena señal de red

### Audio no funciona

1. Verifica que el micrófono no esté silenciado (ícono de micrófono)
2. Revisa los permisos de micrófono en Configuración > Tito
3. Prueba reiniciando la app

### La app se cierra inesperadamente

1. Verifica que tengas suficiente espacio en el dispositivo
2. Cierra otras apps que usen la cámara
3. Reinicia el iPhone si el problema persiste

### Error de conexión RTMP

1. Verifica que la URL del servidor sea correcta
2. Confirma que la clave de transmisión sea válida
3. Asegúrate de que Restream esté activo y aceptando transmisiones
4. Prueba con una conexión Wi-Fi estable

## Arquitectura

La aplicación sigue el patrón MVVM:

- **Models**: StreamConfig, Preset, StreamState, Telemetry
- **ViewModels**: OnboardingViewModel, SettingsViewModel, StreamViewModel
- **Services**: 
  - CameraService: Manejo de la cámara
  - AudioService: Captura de audio
  - EncoderService: Codificación H.264
  - RTMPService: Publicación RTMP usando HaishinKit
  - NetworkMonitor: Monitoreo de red
  - KeychainService: Almacenamiento seguro de credenciales
- **Views**: OnboardingView, ConnectView, PreviewView, LiveView, EndView, DiagnosticsView

## Seguridad

- Las credenciales de Restream se almacenan en el Keychain de iOS
- No se envían datos a servidores externos excepto Restream
- No hay tracking ni analytics de terceros

## Licencia

Este proyecto es de código abierto y está disponible bajo la licencia MIT.

## Soporte

Para problemas o preguntas:
1. Revisa la sección de Solución de Problemas
2. Usa la pantalla de Diagnósticos (tap 5 veces en v1.0)
3. Verifica los logs en Xcode Console

## Changelog

### v1.0
- Lanzamiento inicial
- Transmisión RTMP a Restream
- Tres presets de calidad
- Adaptación automática de bitrate
- Reconexión automática
- Telemetría en tiempo real
