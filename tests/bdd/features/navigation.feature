Feature: Navigation

  Scenario: Homepage displays recipe cards
    Given I am on the homepage
    Then at least one recipe card is visible

  Scenario: Clicking a recipe opens the detail page
    Given I am on the homepage
    When I click on the first visible recipe
    Then I should be on a recipe detail page

  Scenario: Clicking the logo returns to homepage
    Given I am on a recipe detail page
    When I click the logo "Kanpai Ø"
    Then I should be on the homepage
