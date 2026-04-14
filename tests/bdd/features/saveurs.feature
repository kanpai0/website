Feature: Flavor filter (Saveurs)

  Background:
    Given I am on the homepage
    And all filters are reset

  Scenario: All recipes are visible by default
    Then all recipe cards are visible

  Scenario: Selecting a flavor shows only matching recipes
    When I select the flavor "sparkling"
    Then only recipes tagged "sparkling" are visible

  Scenario: Two flavors combine with AND logic
    When I select the flavor "sparkling"
    And I select the flavor "tart"
    Then only recipes tagged with both "sparkling" and "tart" are visible

  Scenario: Deselecting a flavor restores recipes
    When I select the flavor "sweet"
    And I deselect the flavor "sweet"
    Then all recipe cards are visible
