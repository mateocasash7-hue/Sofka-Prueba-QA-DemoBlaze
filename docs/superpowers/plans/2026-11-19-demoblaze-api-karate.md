# Demoblaze API Karate Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Proyecto Gradle + Karate que prueba `POST /signup` y `POST /login` de `https://api.demoblaze.com` en 5 casos, con reporte en `evidencias/`.

**Architecture:** Karate puro con JUnit 5. Las llamadas HTTP viven en los `.feature` (en español). `karate-config.js` expone `baseUrl` y dos funciones (`codificar`, `usuarioUnico`). Un feature helper `crear-usuario.feature` se reutiliza vía `call` para que cada escenario sea independiente.

**Tech Stack:** Java 17, Gradle (wrapper copiado de `../sofka-automation-challenge`), `io.karatelabs:karate-junit5:1.5.1`, JUnit 5.

**Spec:** `docs/superpowers/specs/2026-11-19-demoblaze-api-karate-design.md`

## Global Constraints

- Directorio del proyecto: `C:\Users\Mateo77\Desktop\Repos\sofka-automation-challenge\demoblaze-api-karate`
- Paquete base `co.com.sofka.automation`; runner en `co.com.sofka.automation.runners`
- Features en `src/test/resources/co/com/sofka/automation/features/`, con `# language: es` y `Esquema del escenario` + `Ejemplos`
- `POST` JSON `{"username","password"}`; la contraseña va en **Base64**
- Todas las respuestas son HTTP 200; se valida el body
- Mensajes exactos: `""` (signup ok) · `{"errorMessage":"This user already exist."}` · `"Auth_token: <base64>"` · `{"errorMessage":"Wrong password."}` · `{"errorMessage":"User does not exist."}`
- Username único por ejecución (`karate_<timestamp>_<random>`); nunca usuarios fijos
- `defaultTasks 'clean', 'test'`; `readme.txt` en español; Gradle sin Docker ni servicios extra

## Review Focus

- Si `# language: es` no es soportado por el parser de Karate → fallback a keywords en inglés con nombres de escenario en español (probar primero en Task 1).
- Reintentos/ejecución repetida: usernames no deben colisionar entre ejecuciones consecutivas.
- Password con caracteres especiales o unicode (`Karate#12345`, `Ñandú!`): la codificación Base64 debe ser UTF-8.
- Login de usuario recién creado inmediatamente después del signup (posible consistencia eventual): el helper debe asegurar signup con éxito antes del login.
- Cambio de mensaje del sitio público: las aserciones deben fallar con un diff claro (`match` exacto, no `contains` vago).

---

### Task 1: Esqueleto del proyecto y signup

**Files:**
- Create: `build.gradle`, `settings.gradle`, `gradle.properties`, `.gitignore`, `gradlew`, `gradlew.bat`, `gradle/wrapper/*` (copiar del proyecto Saucedemo)
- Create: `src/test/resources/karate-config.js`
- Create: `src/test/java/co/com/sofka/automation/runners/DemoblazeRunner.java`
- Create: `src/test/resources/co/com/sofka/automation/features/helpers/crear-usuario.feature`
- Create: `src/test/resources/co/com/sofka/automation/features/signup.feature`

**Interfaces:**
- Produces: `karate-config.js` → `baseUrl: string`, `codificar(texto: string): string` (Base64 UTF-8), `usuarioUnico(): string` (`karate_<ts>_<rand>`)
- Produces: `helpers/crear-usuario.feature` → recibe `{username, password}` (password en texto plano), hace signup y devuelve `response` y `username`, `passwordCodificado`; falla si la respuesta no es `""`
- Produces: `DemoblazeRunner` (`@Test void ejecutar()`) corre `classpath:co/com/sofka/automation/features` con `Runner.path(...).parallel(1)` y `assertEquals(0, results.getFailCount())`

- [ ] **Step 1: Copiar wrapper y archivos Gradle** — copiar `gradlew`, `gradlew.bat`, `gradle/wrapper/` y `gradle.properties` de `../sofka-automation-challenge`; escribir `settings.gradle` (`rootProject.name = 'demoblaze-api-karate'`) y `.gitignore` (`build/`, `.gradle/`, `.idea/`, `evidencias/`).
- [ ] **Step 2: `build.gradle`** — plugin `java`; `defaultTasks 'clean','test'`; `testImplementation 'io.karatelabs:karate-junit5:1.5.1'`; `useJUnitPlatform()`; `options.release = 17`, UTF-8; `testLogging.showStandardStreams = true`; `outputs.upToDateWhen { false }`; `sourceSets.test.resources.srcDir 'src/test/java'` no necesario (features en resources). Propiedad `systemProperty 'karate.env', System.getProperty('karate.env', 'dev')`.
- [ ] **Step 3: `karate-config.js`** — `function fn()` devuelve `{ baseUrl: 'https://api.demoblaze.com', codificar: t => Java.type('java.util.Base64').getEncoder().encodeToString(new (Java.type('java.lang.String'))(t).getBytes('UTF-8')), usuarioUnico: () => 'karate_' + Date.now() + '_' + Math.floor(Math.random()*100000) }`.
- [ ] **Step 4: Escribir `signup.feature` (fallará)** — `Esquema del escenario: Signup de un usuario nuevo` y `Escenario: Signup de un usuario ya existente`. Nuevo: `url baseUrl`, `path 'signup'`, `request { username: '#(usuarioUnico())', password: '#(codificar(password))' }`, `method post`, `status 200`, `match response == ''`. Existente: `call read('helpers/crear-usuario.feature')`, repite el signup con el mismo username y `match response == { errorMessage: 'This user already exist.' }`.
- [ ] **Step 5: Escribir `crear-usuario.feature`** — el helper descrito en Interfaces.
- [ ] **Step 6: Escribir `DemoblazeRunner.java`** — como en Interfaces.
- [ ] **Step 7: Ejecutar** `.\gradlew.bat clean test` — esperado: BUILD SUCCESSFUL, 2 escenarios pasan (3 con ejemplos extra: incluir ejemplo con `Ñandú!` en Ejemplos). Si falla por `# language: es`, aplicar fallback (keywords en inglés, nombres en español) y anotarlo en el spec.
- [ ] **Step 8: Commit** (si hay repo git): `git add . && git commit -m "feat: esqueleto karate y pruebas de signup"`

### Task 2: Pruebas de login

**Files:**
- Create: `src/test/resources/co/com/sofka/automation/features/login.feature`

**Interfaces:**
- Consumes: `crear-usuario.feature`, `codificar`, `usuarioUnico`, `baseUrl` (Task 1)

- [ ] **Step 1: Escribir `login.feature` (fallará si algo no cuadra)** con tres escenarios:
  - Login correcto: crear usuario con `call` y hacer `POST /login` con las mismas credenciales; `match response == '#regex Auth_token: .+'`.
  - Password incorrecto: usuario creado + password `wrong_pass` → `match response == { errorMessage: 'Wrong password.' }`.
  - Usuario inexistente: `usuarioUnico()` sin crear → `match response == { errorMessage: 'User does not exist.' }`.
  - Los tres usan `Esquema del escenario` con `Ejemplos` (usuario, password).
- [ ] **Step 2: Ejecutar** `.\gradlew.bat clean test` — esperado: BUILD SUCCESSFUL, 5 escenarios (más ejemplos) en verde.
- [ ] **Step 3: Verificar que fallan bien** — cambiar temporalmente un mensaje esperado y confirmar que el reporte muestra el diff; revertir.
- [ ] **Step 4: Commit**: `git add . && git commit -m "feat: pruebas de login"`

### Task 3: Reporte en evidencias y readme

**Files:**
- Modify: `build.gradle` (tarea `copiarEvidencias`, `test.finalizedBy`)
- Create: `readme.txt`

**Interfaces:**
- Consumes: reporte Karate generado en `build/karate-reports/`

- [ ] **Step 1: Tarea Gradle `copiarEvidencias`** (tipo `Copy`) de `build/karate-reports` a `evidencias/karate-report`; `test.finalizedBy(copiarEvidencias)`.
- [ ] **Step 2: Escribir `readme.txt`** con el mismo formato del proyecto Saucedemo: verificar Java 17, clonar, ubicarse en la carpeta, ejecutar (`gradlew clean test` en cmd / `.\gradlew.bat clean test` en PowerShell / `./gradlew clean test` en Mac-Linux-Git Bash), verificar `BUILD SUCCESSFUL`, abrir `evidencias/karate-report/karate-summary.html`.
- [ ] **Step 3: Ejecución final** `.\gradlew.bat` (solo defaultTasks) — esperado: BUILD SUCCESSFUL y `evidencias/karate-report/karate-summary.html` existe con 0 fallas.
- [ ] **Step 4: Commit**: `git add . && git commit -m "docs: readme y evidencias"`

## Self-Review

- Cobertura del spec: 5 casos (Tasks 1–2), estructura, runner, config, helper, reporte y readme (Tasks 1–3). Cambio respecto al spec: las utilidades Base64/username viven en `karate-config.js` en lugar de una carpeta `helpers/` de JS; el helper de feature sí está en `helpers/`.
- Consistencia: `codificar`, `usuarioUnico`, `baseUrl` y `crear-usuario.feature` se usan con los mismos nombres en todas las tareas.
- Riesgo abierto: soporte de `# language: es` en Karate 1.5.1 (ver Review Focus y Task 1 Step 7).
