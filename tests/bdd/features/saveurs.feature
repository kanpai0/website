Feature: Flavor filter (Saveurs)

  Background:
    Given I am on the homepage
    And all filters are reset

  Scenario: All recipes are visible by default
    Then all recipe cards are visible

  Scenario: Selecting a flavor shows only matching recipes
    When I select the flavor "petillant"
    Then only recipes tagged "petillant" are visible

  Scenario: Two flavors combine with AND logic
    When I select the flavor "petillant"
    And I select the flavor "acidule"
    Then only recipes tagged with both "petillant" and "acidule" are visible

  Scenario: Deselecting a flavor restores recipes
    When I select the flavor "sucre"
    And I deselect the flavor "sucre"
    Then all recipe cards are visible
