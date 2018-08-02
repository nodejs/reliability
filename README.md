# Node.js Core CI Reliability

This repo is used for tracking flaky tests on the Node.js CI and fixing them.

**Current status**: work in progress. Please go to the issue tracker to discuss!

<!-- TOC -->

- [Updating this repo](#updating-this-repo)
- [The Goal](#the-goal)
    - [The Definition of Green](#the-definition-of-green)
- [CI Health History](#ci-health-history)
- [Handling Failed CI runs](#handling-failed-ci-runs)
    - [Flaky Tests](#flaky-tests)
        - [Identifying Flaky Tests](#identifying-flaky-tests)
        - [When Discovering a Potential New Flake on the CI](#when-discovering-a-potential-new-flake-on-the-ci)
    - [Infrastructure failures](#infrastructure-failures)
    - [Build File Failures](#build-file-failures)
- [TODO](#todo)

<!-- /TOC -->

## Updating this repo

Updates should be merged as soon as possible. We can revert or modify
afterwards. This repo is mostly for coordination so we need to move fast and
reduce the noise.

## The Goal

Make the CI green again.

- Taking actual failures from PRs into account, at least 80% of the
  [node-test-pull-request](https://ci.nodejs.org/job/node-test-pull-request/)
  (or [node-test-commit](https://ci.nodejs.org/job/node-test-commit)) CI runs
  should be green.
- At least 90% of the [node-daily-master](https://ci.nodejs.org/view/Node.js%20Daily/job/node-daily-master/)
  CI should be green.

### The Definition of Green

- A green CI run is a run with a SUCCESS status, UNSTABLE does not count as
  green
- Taking the last 100 runs, at any given time the green rate is calculated as
  follows

  ```
  SUCCESS / (100 - RUNNING - ABORTED)
  ```

## CI Health History

See https://nodejs-ci-health.mmarchini.me/#/job-summary

| UTC Time         | RUNNING | SUCCESS | UNSTABLE | ABORTED | FAILURE | Green Rate |
| ---------------- | ------- | ------- | -------- | ------- | ------- | ---------- |
| 2018-06-01 20:00 | 1       | 1       | 15       | 11      | 72      | 1.13%      |
| 2018-06-03 11:36 | 3       | 6       | 21       | 10      | 60      | 6.89%      |
| 2018-06-04 15:00 | 0       | 9       | 26       | 10      | 55      | 10.00%     |
| 2018-06-15 17:42 | 1       | 27      | 4        | 17      | 51      | 32.93%     |
| 2018-06-24 18:11 | 0       | 27      | 2        | 8       | 63      | 29.35%     |
| 2018-07-08 19:40 | 1       | 35      | 2        | 4       | 58      | 36.84%     |
| 2018-07-18 20:46 | 2       | 38      | 4        | 5       | 51      | 40.86%     |
| 2018-07-24 22:30 | 2       | 46      | 3        | 4       | 45      | 48.94%     |
| 2018-08-01 19:11 | 4       | 17      | 2        | 2       | 75      | 18.09%     |

## Handling Failed CI runs

### Flaky Tests

TODO: automate all of this in ncu-ci

#### Identifying Flaky Tests

When checking the CI results of a PR, if there is one or more failed tests (with
`not ok` as the TAP result):

1.  If the failed test is not related to the PR (does not touch the modified
    code path), search the test name in the issue tracker of this repo. If there
    is an existing issue, add a reply there using the [reproduction template](./templates/repro.txt),
    and open a pull request updating `flakes.json`.
2.  If there are no new existing issues about the test, run the CI again. If the
    failure disappears in the next run, then it is potential flake. See
    [When discovering a potential flake on the CI](#when-discovering-a-potential-new-flake-on-the-ci)
    on what to do for a new flake.
3.  If the failure reproduces in the next run, it is likely that the failure is
    related to the PR. Do not re-run CI without code changes in the next 24
    hours, try to debug the failure.
4.  If the cause of the failure still cannot be identified 24 hours later, and
    the code has not been changed, start a CI run and see if the failure
    disappears. Go back to step 3 if the failure still reproduces, and go to
    step 2 if the failure disappears.

#### When Discovering a Potential New Flake on the CI

1.  Open an issue in this repo using [the flake issue template](./templates/flake.txt):

    - Title should be `Investigate path/under/the/test/directory/without/extension`,
      for example `Investigate async-hooks/test-zlib.zlib-binding.deflate`.

2.  Add the `Flaky Test` label and relevant subsystem labels (TODO: create
    useful labels).

3.  Open a pull request updating `flakes.json`.

4.  Notify the subsystem team related to the flake.

### Infrastructure failures

When the CI run fails because:

- There are network connection issues
- There are tests fail with `ENOSPAC` (No space left on device)
- The CI machine has trouble pulling source code from the repository

Do the following:

1.  Search in this repo with the error message and see if there is any open
    issue about this.
2.  If there is an existing issue, wait until the problem gets fixed.
3.  If there are no similar issues, open a new one with
    [the build infra issue template](./templates/infra.txt).
4.  Add label `Build Infra`.
5.  Notify the `@nodejs/build-infra` team in the issue.

### Build File Failures

When the CI run of a PR that does not touch the build files ends with build
failures (e.g. the run ends before the test runner has a chance to run):

1.  Search in this repo with the error message that contains keywords like
    `fatal`, `error`, etc.
2.  If there is a similar issue, add a reply there using the
    [reproduction template](./templates/build-file-repro.txt).
3.  If there are no similar issues, open a new one with
    [the build file issue template](./templates/build-file.txt).
4.  Add label `Build Files`.
5.  Notify the `@nodejs/build-files` team in the issue.

## TODO

- [ ] Settle down on the flake database schema
- [ ] Read the flake database in ncu-ci so people can quickly tell if
      a failure is a flake
- [ ] Automate the report process in ncu-ci
- [ ] Migrate existing issues in nodejs/node and nodejs/build, close outdated
      ones.
- [ ] Automate CI health history tracking
