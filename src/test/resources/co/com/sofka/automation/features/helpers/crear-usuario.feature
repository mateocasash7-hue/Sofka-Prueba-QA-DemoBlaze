# Helper reutilizable: crea un usuario en Demoblaze. Recibe username y password (texto plano).
@ignore
Feature: Crear usuario (helper)

  Scenario: Crear usuario en signup
    * def passwordCodificado = codificar(password)
    Given url baseUrl
    And path 'signup'
    And request { username: '#(username)', password: '#(passwordCodificado)' }
    When method post
    Then status 200
    # La API responde el texto con comillas y salto de línea, por eso lo recorto
    * def cuerpo = karate.toString(response).trim()
    And match cuerpo == '""'
