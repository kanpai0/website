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

  Scenario: Counter is hidden when no filter is active
    Then the filter summary is hidden

  Scenario: Counter shows the correct number of hidden recipes
    When I open the fridge panel
    And I uncheck the ingredient "rhum"
    And I close the fridge panel
    Then the filter summary shows the count of hidden recipes

  Scenario: Fridge and flavor filters combine with AND logic
    When I select the flavor "sparkling"
    And I open the fridge panel
    And I uncheck the ingredient "rhum"
    And I close the fridge panel
    Then no visible recipe requires "rhum"
    And no visible recipe lacks the flavor "sparkling"

  Scenario: Corrupted fridge localStorage falls back to the default (all recipes visible)
    Given the fridge localStorage contains invalid JSON
    Then all recipe cards are visible

  Scenario: Stale fridge slugs in localStorage are dropped, valid ones still apply
    Given the fridge localStorage contains stale slugs
    Then the recipe "caipirinha" is visible
    And the recipe "amaretto-sour" is hidden

  Scenario: The fridge panel still works after a corrupted localStorage value
    Given the fridge localStorage contains invalid JSON
    When I open the fridge panel
    And I uncheck the ingredient "rhum"
    And I close the fridge panel
    Then recipes requiring "rhum" are hidden
