# Autor: Mateo Casas H (mateocasash7@gmail.com)

@login
Feature: Inicio de sesión en Demoblaze
  Como usuario registrado de Demoblaze
  Quiero iniciar sesión con mi usuario y contraseña
  Para obtener acceso a mi cuenta

  Scenario Outline: Login con usuario y password correctos
    * def usuario = usuarioUnico()
    * call read('helpers/crear-usuario.feature') { username: '#(usuario)', password: '#(password)' }
    * def passwordCodificado = codificar(password)
    Given url baseUrl
    And path 'login'
    And request { username: '#(usuario)', password: '#(passwordCodificado)' }
    When method post
    Then status 200
    * def cuerpo = karate.toString(response).trim()
    And match cuerpo == '#regex "Auth_token: .+"'

    Examples:
      | password     |
      | Karate#12345 |
      | Ñandú!2026   |

  Scenario Outline: Login con password incorrecto
    * def usuario = usuarioUnico()
    * call read('helpers/crear-usuario.feature') { username: '#(usuario)', password: '#(password)' }
    * def passwordCodificado = codificar(passwordIncorrecto)
    Given url baseUrl
    And path 'login'
    And request { username: '#(usuario)', password: '#(passwordCodificado)' }
    When method post
    Then status 200
    And match response == { errorMessage: 'Wrong password.' }

    Examples:
      | password     | passwordIncorrecto |
      | Karate#12345 | wrong_pass         |

  Scenario Outline: Login con usuario inexistente
    * def usuario = usuarioUnico()
    * def passwordCodificado = codificar(password)
    Given url baseUrl
    And path 'login'
    And request { username: '#(usuario)', password: '#(passwordCodificado)' }
    When method post
    Then status 200
    And match response == { errorMessage: 'User does not exist.' }

    Examples:
      | password     |
      | Karate#12345 |
