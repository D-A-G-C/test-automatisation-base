Feature: Test de servicio marvel-api

  Background:
    * url 'http://localhost:8080'
    * def username = 'digarcia'
    * configure ssl = true

  Scenario: Obtener todos los personajes (flujo feliz)
    Given path username, 'api', 'characters'
    When method get
    Then status 200

  Scenario: Crear personaje exitosamente (flujo feliz)
    Given path username, 'api', 'characters'
    And request
      """
      {
        "name": "Iron Man",
        "alterego": "Tony Stark",
        "description": "Genius billionaire",
        "powers": ["Armor", "Flight"]
      }
      """
    When method post
    Then status 201
    And match response.name == 'Iron Man'
    * def characterId = response.id

  Scenario: Crear personaje con nombre duplicado (flujo triste)
    Given path username, 'api', 'characters'
    And request
      """
      {
        "name": "Iron Man",
        "alterego": "Otro",
        "description": "Otro",
        "powers": ["Armor"]
      }
      """
    When method post
    Then status 400

  Scenario: Crear personaje con campos requeridos vacíos (flujo triste)
    Given path username, 'api', 'characters'
    And request
      """
      {
        "name": "",
        "alterego": "",
        "description": "",
        "powers": []
      }
      """
    When method post
    Then status 400

  Scenario: Obtener personaje por ID (no existe)
    Given path username, 'api', 'characters', 999
    When method get
    Then status 404
    And match response.error == 'Character not found'

  Scenario: Actualizar personaje (no existe)
    Given path username, 'api', 'characters', 999
    And request
      """
      {
        "name": "Iron Man",
        "alterego": "Tony Stark",
        "description": "Updated description",
        "powers": ["Armor", "Flight"]
      }
      """
    When method put
    Then status 404
    And match response.error == 'Character not found'

  Scenario: Eliminar personaje (no existe)
    Given path username, 'api', 'characters', 999
    When method delete
    Then status 404
    And match response.error == 'Character not found'

  Scenario: Flujo completo de personaje (crear, obtener, actualizar, eliminar)
    # Crear personaje
    Given path username, 'api', 'characters'
    And request
      """
      {
        "name": "Spider-Man",
        "alterego": "Peter Parker",
        "description": "Superhéroe arácnido de Marvel",
        "powers": [
          "Agilidad",
          "Sentido arácnido",
          "Trepar muros"
        ]
      }
      """
    When method post
    Then status 201
    * def characterId = response.id

    # Obtener personaje por ID
    Given path username, 'api', 'characters', characterId
    When method get
    Then status 200
    And match response.id == characterId

    # Actualizar personaje
    Given path username, 'api', 'characters', characterId
    And request
      """
      {
        "name": "Spider-Man",
        "alterego": "Peter Parker",
        "description": "Superhéroe arácnido de Marvel",
        "powers": [
          "Agilidad",
          "Sentido arácnido",
          "Trepar muros",
          "Lanzar telarañas"
        ]
      }
      """
    When method put
    Then status 200
    And match response.powers[3] == 'Lanzar telarañas'

    # Eliminar personaje
    Given path username, 'api', 'characters', characterId
    When method delete
    Then status 204