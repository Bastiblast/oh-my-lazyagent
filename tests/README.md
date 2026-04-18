Testing Strategy for Wave 7 Components - E2E and Unit Tests

- Overview
  - This repository includes end-to-end tests (e2e) and unit tests to cover the Wave 7 escalation flow and related config/patch tooling.
  - E2E tests target the Big-Brother escalation integration with mocked subsystems.

- Test Organization
  - tests/e2e: End-to-end tests that exercise full flows with mocks.
  - tests/unit: Unit tests for helper utilities and scripts used by the application.
  - tests/README.md: This document, describes how to run tests locally and in CI.

- Running Tests
  - Unit tests (config merge, patch apply, etc.):
    - npm run test:unit
    - Or: npx jest tests/unit --runInBand
  - End-to-end tests:
    - npm run test:e2e
    - Or: npx jest tests/e2e --runInBand
  - Ensure dependencies are installed before running tests (npm install).

- Test Dependencies and Mocks
  - Tests are written in TypeScript using Jest-style syntax (describe/it/expect).
  - OmO dependencies are mocked/stubbed within tests to simulate real interactions.
  - Test files intentionally avoid touching real external services.

- Adding New Tests
  - Create a new file under tests/unit or tests/e2e depending on scope.
  - Follow existing test naming conventions and add descriptive test names.
  - Ensure tests export nothing; jest will discover via file naming patterns.

- CI/CD Integration Notes
  - Run unit tests on push/PRs, and run e2e tests on feature branches or on a dedicated CI job.
  - Use caching where possible to speed up installs (npm ci, etc.).
  - Consider running e2e tests in a lightweight docker image if integration with external services is restricted.
