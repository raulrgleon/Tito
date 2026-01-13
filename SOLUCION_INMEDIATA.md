# 🚨 Solución Inmediata: Errores "Cannot find in scope"

Estos errores ocurren porque los archivos **existen físicamente** pero **NO están agregados al target de compilación** en Xcode.

## ✅ Solución Rápida (3 pasos)

### Paso 1: Cerrar Xcode
Cierra Xcode completamente (⌘Q)

### Paso 2: Agregar Archivos al Target

**Opción A: Arrastrar desde Finder (MÁS FÁCIL)**

1. Abre **Finder** y navega a:
   ```
   /Users/raul/Downloads/Tito/Tito/
   ```

2. Abre **Xcode** y abre el proyecto `Tito.xcodeproj`

3. En el **navegador izquierdo de Xcode**, verás la carpeta "Tito"

4. **Arrastra estas 4 carpetas** desde Finder al proyecto en Xcode:
   - `Models` 
   - `Services`
   - `ViewModels`
   - `Views`

5. Cuando aparezca el diálogo:
   - ✅ **DESMARCA** "Copy items if needed"
   - ✅ **SELECCIONA** "Create groups" (no "Create folder references")
   - ✅ **MARCA** el target "Tito" (MUY IMPORTANTE)
   - Haz clic en **"Finish"**

**Opción B: Add Files to Tito**

1. En Xcode, haz **clic derecho** en la carpeta "Tito" en el navegador
2. Selecciona **"Add Files to Tito..."**
3. Selecciona las carpetas: `Models`, `Services`, `ViewModels`, `Views`
4. ✅ **DESMARCA** "Copy items if needed"
5. ✅ **SELECCIONA** "Create groups"
6. ✅ **MARCA** el target "Tito"
7. Haz clic en **"Add"**

### Paso 3: Verificar Target Membership

1. Selecciona el proyecto "Tito" en el navegador
2. Selecciona el target "Tito"
3. Ve a **"Build Phases"**
4. Expande **"Compile Sources"**
5. Deberías ver **21 archivos Swift** listados

Si faltan archivos:
- Selecciona cada archivo `.swift` individualmente
- En el panel derecho, ve a **"File Inspector"** (primer ícono)
- En **"Target Membership"**, marca **"Tito"**

### Paso 4: Compilar

1. Presiona **⌘B** para compilar
2. Los errores deberían desaparecer
3. Si compila bien, presiona **⌘R** para ejecutar

---

## 🔍 Verificación Rápida

Después de agregar los archivos, verifica en Xcode:

1. **Build Phases > Compile Sources** debe tener ~21 archivos
2. Cada archivo debe tener un checkmark ✅ junto al nombre
3. Si un archivo tiene un ⚠️ o no aparece, no está en el target

---

## ⚠️ Si Aún Ves Errores

### Error: "Cannot find 'X' in scope"

Esto significa que el archivo que define 'X' no está en el target.

**Solución:**
1. Busca el archivo que define 'X' (ej: `OnboardingViewModel.swift`)
2. Selecciónalo en el navegador
3. Panel derecho > File Inspector > Target Membership
4. Marca "Tito"

### Error: "No such module 'HaishinKit'"

**Solución:**
1. File > Add Package Dependencies...
2. URL: `https://github.com/shogo4405/HaishinKit.swift.git`
3. Versión: `1.5.0` o superior
4. Target: "Tito"

---

## ✅ Checklist Final

Antes de ejecutar, verifica:

- [ ] Las 4 carpetas (Models, Services, ViewModels, Views) están en el navegador de Xcode
- [ ] Build Phases > Compile Sources tiene ~21 archivos
- [ ] Todos los archivos tienen checkmark ✅
- [ ] El proyecto compila sin errores (⌘B)
- [ ] HaishinKit está agregado como dependencia (si es necesario)

---

## 🆘 Si Nada Funciona

Comparte:
1. Una captura de pantalla de "Build Phases > Compile Sources"
2. El número de archivos que ves listados
3. Cualquier otro error que aparezca
