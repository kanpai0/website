Feature: Fridge filter (Mon frigo)

  Background:
    Given I am on the homepage
    And all filters are reset

  Scenario: Opening the fridge panel
    When I open the fridge panel
    Then the fridge panel is visible

  Scenario: Closing the fridge panel
    When I open the fridge panel
    And I close the fridge panel
    Then the fridge panel is hidden

  Scenario: Unchecking an ingredient hides recipes that require it
    When I open the fridge panel
    And I uncheck the ingredient "rhum"
    And I close the fridge panel
    Then recipes requiring "rhum" are hidden

  Scenario: Fridge and flavor filters combine with AND logic
    When I select the flavor "sparkling"
    And I open the fridge panel
    And I uncheck the ingredient "rhum"
    And I close the fridge panel
    Then no visible recipe requires "rhum"
    And no visible recipe lacks the flavor "sparkling"
