# Autor: Mateo Casas H (mateocasash7@gmail.com)

@signup
Feature: Registro de usuarios en Demoblaze
  Como visitante de Demoblaze
  Quiero registrarme con un usuario y una contraseña
  Para poder iniciar sesión después

  Scenario Outline: Crear un nuevo usuario en signup
    * def usuario = usuarioUnico()
    * def passwordCodificado = codificar(password)
    Given url baseUrl
    And path 'signup'
    And request { username: '#(usuario)', password: '#(passwordCodificado)' }
    When method post
    Then status 200
    # La API responde el texto con comillas y salto de línea, por eso lo recorto
    * def cuerpo = karate.toString(response).trim()
    And match cuerpo == '""'

    Examples:
      | password     |
      | Karate#12345 |
      | Ñandú!2026   |

  Scenario Outline: Intentar crear un usuario ya existente
    * def usuario = usuarioUnico()
    * call read('helpers/crear-usuario.feature') { username: '#(usuario)', password: '#(password)' }
    * def passwordCodificado = codificar(password)
    Given url baseUrl
    And path 'signup'
    And request { username: '#(usuario)', password: '#(passwordCodificado)' }
    When method post
    Then status 200
    And match response == { errorMessage: 'This user already exist.' }

    Examples:
      | password     |
      | Karate#12345 |
