PASOS DE EJECUCIÓN - PRUEBAS DE API (SIGNUP Y LOGIN) DE DEMOBLAZE CON KARATE
============================================================================

Servicios probados:
  Signup: https://api.demoblaze.com/signup
  Login:  https://api.demoblaze.com/login

Casos cubiertos:
  1. Crear un nuevo usuario en signup
  2. Intentar crear un usuario ya existente
  3. Login con usuario y password correctos
  4. Login con password incorrecto
  5. Login con usuario inexistente

Datos importantes de la API:
  - El frontend envía la contraseña codificada en Base64, por eso las pruebas la codifican.
  - La API responde HTTP 200 incluso en los errores; el error viene en el body:
      {"errorMessage":"This user already exist."}
      {"errorMessage":"Wrong password."}
      {"errorMessage":"User does not exist."}
  - El sitio no valida datos y es público, por eso cada ejecución crea usuarios nuevos y únicos
    (karate_<fecha>_<número>) y no depende de usuarios que ya existan.

Paso 1. Verificar que Java 17 o superior esté instalado:
          java -version

Paso 2. Clonar el repositorio:
          git clone https://github.com/mateocasash7-hue/Sofka-Prueba-QA-DemoBlaze.git

Paso 3. Ubicarse en la carpeta del proyecto:
          cd Sofka-Prueba-QA-DemoBlaze

Paso 4. Ejecutar las pruebas según la terminal (requiere conexión a internet):
          Windows (cmd):          gradlew clean test
          Windows (PowerShell):   .\gradlew.bat clean test
          Mac / Linux / Git Bash: ./gradlew clean test

Paso 5. Verificar que la consola finalice con:
          BUILD SUCCESSFUL

Paso 6. Abrir el reporte de Karate en el navegador:
          evidencias/karate-report/karate-summary.html
