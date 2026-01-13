# Solución: No Puedo Ejecutar el Proyecto

Sigue estos pasos en orden para diagnosticar y resolver el problema:

## 🔍 Paso 1: Verificar Errores de Compilación

1. En Xcode, presiona **⌘B** para compilar
2. Revisa el panel de errores (parte inferior de Xcode)
3. Si hay errores, compártelos conmigo

### Errores Comunes:

#### ❌ "No such module 'HaishinKit'"
**Solución:**
1. Ve a **File > Add Package Dependencies...**
2. Pega esta URL: `https://github.com/shogo4405/HaishinKit.swift.git`
3. Selecciona "Up to Next Major Version" y pon `1.5.0`
4. Haz clic en "Add Package"
5. Asegúrate de que el target "Tito" esté seleccionado
6. Haz clic en "Add Package" nuevamente
7. Espera a que descargue (puede tardar 1-2 minutos)
8. Intenta compilar nuevamente (⌘B)

#### ❌ "Signing for Tito requires a development team"
**Solución:**
1. Selecciona el proyecto "Tito" en el navegador izquierdo
2. Selecciona el target "Tito"
3. Ve a la pestaña **"Signing & Capabilities"**
4. Marca la casilla **"Automatically manage signing"**
5. En **"Team"**, selecciona tu equipo de desarrollo
   - Si no tienes uno, crea una cuenta gratuita en [developer.apple.com](https://developer.apple.com)
   - O selecciona "Add an Account..." y sigue las instrucciones
6. Xcode generará automáticamente un perfil de aprovisionamiento

#### ❌ "No such file or directory"
**Solución:**
1. Verifica que todos los archivos estén agregados al target:
   - Selecciona cada archivo `.swift` en el navegador
   - En el panel derecho, ve a "File Inspector" (primer ícono)
   - Asegúrate de que el target "Tito" esté marcado en "Target Membership"

## 🔍 Paso 2: Verificar que Todos los Archivos Estén en el Target

1. Selecciona el proyecto "Tito" en el navegador
2. Selecciona el target "Tito"
3. Ve a **"Build Phases"**
4. Expande **"Compile Sources"**
5. Deberías ver aproximadamente 21 archivos `.swift`

Si faltan archivos:
1. Selecciona los archivos faltantes en el navegador
2. En el panel derecho, marca el target "Tito" en "Target Membership"

## 🔍 Paso 3: Verificar Dispositivo Seleccionado

1. En la barra superior de Xcode, verifica el selector de dispositivos
2. Selecciona tu iPhone físico (no el simulador)
3. Si no aparece tu iPhone:
   - Conecta tu iPhone con cable USB
   - Desbloquea tu iPhone
   - Confía en la computadora cuando aparezca el mensaje

## 🔍 Paso 4: Limpiar y Recompilar

1. Ve a **Product > Clean Build Folder** (⇧⌘K)
2. Cierra Xcode completamente
3. Elimina los archivos derivados:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/Tito-*
   ```
4. Abre Xcode nuevamente
5. Abre el proyecto
6. Intenta compilar (⌘B)
7. Si compila sin errores, intenta ejecutar (⌘R)

## 🔍 Paso 5: Verificar Dependencias de Swift Package Manager

1. Ve a **File > Packages > Reset Package Caches**
2. Luego **File > Packages > Update to Latest Package Versions**
3. Espera a que termine
4. Intenta compilar nuevamente

## 📋 Checklist Rápido

Antes de ejecutar, verifica:

- [ ] Todos los archivos Swift están en el target "Tito"
- [ ] HaishinKit está agregado como dependencia
- [ ] El equipo de desarrollo está configurado en Signing & Capabilities
- [ ] Un dispositivo iPhone está seleccionado (no simulador)
- [ ] El proyecto compila sin errores (⌘B funciona)
- [ ] El iPhone está conectado y desbloqueado

## 🆘 Si Nada Funciona

Comparte conmigo:
1. El mensaje de error exacto que aparece en Xcode
2. Una captura de pantalla del panel de errores (⌘⇧Y)
3. Qué aparece en "Build Phases > Compile Sources"

Con esa información podré ayudarte mejor.
