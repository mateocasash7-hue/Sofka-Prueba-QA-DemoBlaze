# Diseño: pruebas de API Demoblaze con Karate

Fecha: 2026-11-19 · Estado: aprobado por el usuario

## Intención
Probar los servicios REST de signup y login de https://www.demoblaze.com (`https://api.demoblaze.com`) con Karate, replicando la estructura del proyecto Saucedemo (Gradle, runner en `runners`, features en español, reporte en `evidencias/`, `readme.txt`).

## Alcance
Cuatro casos pedidos (más uno): signup usuario nuevo, signup usuario existente, login correcto, login con password incorrecto, login con usuario inexistente.

## No objetivos
No pruebas de UI, no carga, no seguridad. No usar usuarios fijos del sitio público.

## Hallazgos de la API (capturados con Chrome, 2026-11-19)
- `POST /signup` y `POST /login`, `Content-Type: application/json`, body `{"username": "...", "password": "<Base64 de la contraseña>"}`. La contraseña viaja en Base64.
- Todas las respuestas son HTTP 200; el error va en el body.

| Caso | Body de respuesta |
|---|---|
| signup nuevo | `""` |
| signup existente | `{"errorMessage":"This user already exist."}` |
| login correcto | `"Auth_token: <base64>"` |
| login password incorrecto | `{"errorMessage":"Wrong password."}` |
| login usuario inexistente | `{"errorMessage":"User does not exist."}` |

El sitio no valida datos: acepta cualquier usuario/contraseña.

## Enfoques considerados
1. **Karate puro + JUnit 5 + Gradle (elegido):** el más simple, las llamadas HTTP viven en el `.feature`; encaja con el estilo Gradle existente.
2. Karate + Serenity: añade reporte Serenity pero complica dependencias sin aportar valor para API.
3. Postman/Newman: no es Karate, descartado.

## Diseño
- `build.gradle`: Java 17, Karate 1.5.x (`karate-junit5`), `defaultTasks 'clean','test'`, copia del reporte a `evidencias/`.
- `src/test/java/co/com/sofka/automation/runners/DemoblazeRunner.java`: ejecuta los features, escribe reporte HTML.
- `src/test/java/karate-config.js` (o resources): `baseUrl = https://api.demoblaze.com`.
- `src/test/resources/co/com/sofka/automation/features/signup.feature` y `login.feature` (`# language: es`, Esquema del escenario + Ejemplos).
- `.../helpers/crear-usuario.feature` (reutilizable vía `call`) y utilidades Base64 + username único (`karate_<timestamp>_<random>`).
- Login correcto: crea usuario nuevo con `call` y luego hace login (escenarios independientes).
- Validaciones sobre el body (el status siempre es 200), más tipo de contenido.
- `readme.txt` con pasos de ejecución.

## Decisiones del builder (mías)
- Nombre de proyecto: `demoblaze-api-karate`, paquete base `co.com.sofka.automation`.
- Datos de prueba en `Ejemplos` de los features; el username único se genera por ejecución.
- Sin git en el directorio actual, por lo que el spec no se commitea.
