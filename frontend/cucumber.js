// WHY THIS FILE EXISTS: Cucumber.js configuration file.
// Wires feature files to step definitions and support files.
// allure-cucumberjs formatter is added alongside the standard reporters so
// Cucumber BDD results feed into the mandatory Allure dashboard.
// To add a new bounded context: add its step definitions directory to 'require'.
// To add tags for selective test runs: use --tags @smoke or --tags @regression.

module.exports = {
  default: {
    require: [
      'e2e/support/world.ts',
      'e2e/support/hooks.ts',
      'e2e/steps/**/*.ts',
    ],
    requireModule: ['ts-node/register'],
    format: [
      'progress-bar',
      'html:cucumber-report.html',
      'junit:cucumber-report.xml',
      // Allure formatter: writes JSON results to allure-results/
      // consumed by the CI 'allure:generate' job and npm run allure:generate
      ['allure-cucumberjs/reporter', { resultsDir: 'allure-results' }],
    ],
    paths: ['e2e/features/**/*.feature'],
    publishQuiet: true,
  },
};
