# WHY THIS FILE EXISTS: BDD scenarios for the application shell (header, footer, a11y).
# This is the baseline feature that verifies the scaffold works correctly.
# All new features get their own .feature file in a bounded-context subdirectory.

Feature: Application Shell
  As a user
  I want the application to have a proper page structure
  So that I can navigate it with a keyboard and screen reader

  @smoke
  Scenario: Page loads with accessible structure
    Given I open the application home page
    Then the page should have a skip to main content link
    And the page should have a header
    And the page should have a main content area
    And the page should have a footer
    And the page should have no accessibility violations
