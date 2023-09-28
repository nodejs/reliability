# Node.js Core CI Reliability

This repo is used for tracking flaky tests on the Node.js CI and fixing them.

**Current status**: work in progress. Please go to the issue tracker to discuss!

<!-- TOC -->
- [Node.js Core CI Reliability](#nodejs-core-ci-reliability)
  - [Updating this repo](#updating-this-repo)
  - [The Goal](#the-goal)
    - [The Definition of Green](#the-definition-of-green)
  - [CI Health History](#ci-health-history)
  - [Protocols in improving CI reliability](#protocols-in-improving-ci-reliability)
    - [Identifying flaky JS tests](#identifying-flaky-js-tests)
    - [Handling flaky JS tests](#handling-flaky-js-tests)
    - [Identifying infrastructure issues](#identifying-infrastructure-issues)
    - [Handling infrastructure issues](#handling-infrastructure-issues)
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

[A GitHub workflow](.github/workflows/reliability_report.yml) is run every day
to produce reliability reports of the `node-test-pull-request` CI and post
it to [the issue tracker](https://github.com/nodejs/reliability/issues).

## Protocols in improving CI reliability

Most work starts with opening the issue tracker of this repository and
reading the latest report. If the report is missing, see
[the actions page](https://github.com/nodejs/reliability/actions) for
details. GitHub's API restricts the length of issue messages, so
whenever the report is too long the workflow can fail to post the
issue. But it should still leave a summary in the actions page.

### Identifying flaky JS tests

1. Check out the `JSTest Failure` section of the latest reliability report.
    It contains information about the JS tests that failed more than 1 pull
    requests in the last 100 `node-test-pull-request` CI runs. The more
    pull requests a test fail, the higher it would be ranked, and the more
    likely that it is a flake.
2. Search the name of the test in [the Node.js issue tracker](https://github.com/nodejs/node/issues)
    and see if there is already an issue about it. If there is already
    an issue, check if the failures are similar. Comment with updates
    if necessary.
3. If the flake isn't already tracked by an issue, continue to look into
   it. In the report of a JS test, check out the pull requests that it
   fails and see if there is a connection. If the pull requests appear to
   be unrelated, it is more likely that the test is a flake.
4. Search the historical reliability reports with the name of the test in
   the reliability issue tracker, and see how long the flake has been showing
   up. Gather information from the historical reports, and
   [open an issue](https://github.com/nodejs/node/issues/new?assignees=&labels=flaky-test&projects=&template=4-report-a-flaky-test.yml)
   in the Node.js issue tracker to track the flake.

### Handling flaky JS tests

1. If the flake only starts to show up in the recent month, check the
   historical reports to see precisely when it starts to show up. Look at
   commits landing on the target branch around the same time using
   `https://github.com/nodejs/node/commits?since=YYYY-MM-DD`
   and see if there is any pull request that looks related. If one or
   more related pull requests can be found, ping the author or the
   reviewer of the pull request, or the team in charge of the
   related subsystem in the tracking issue or in private to see if
   they can come up with a fix to just deflake the test.
2. If the test has been flaky for more than a month and no one is actively
   working on it, it is unlikely to go away on its own, and it's time
   to mark it as flaky. For example, if `parallel/some-flaky-test.js`
   has been flaky on Windows in the CI, after making sure that there is an
   issue tracking it, open a pull request to add the following entry to
   [`test/parallel/parallel.status`](https://github.com/nodejs/node/tree/main/test/parallel/parallel.status):

    ```
    [$system==win32]
    # https://github.com/nodejs/node/issues/<TRACKING_ISSUE_ID>
    some-flaky-test: PASS,FLAKY
    ```

### Identifying infrastructure issues

In the reliability reports, `Jenkins Failure`, `Git Failure` and
`Build Failure` are generally infrastructure issues and can be
handled by the `nodejs/build` team. Typical infrastructure
issues include:

- The CI machine has trouble pulling source code from the repository
- The CI machine has trouble communicating to the Jenkins server
- Build timing out
- Parent job fails to trigger sub builds

Sometimes infrastructure issues can show up in the tests too, for
example tests can fail with `ENOSPAC` (No space left on device), and
the machine needs to be cleaned up to release disk space.

Some infrastructure issues can go away on its own, but if the same kind
of infrastructure issue has been failing multiple pull requests and
persists for more than a day, it's time to take action.

### Handling infrastructure issues

Check out the [Node.js build issue tracker](https://github.com/nodejs/build/issues)
to see if there is any open issue about this. If there isn't,
open a new issue about it or ask around in the `#nodejs-build` channel
in the OpenJS slack.

When reporting infrastructure issues, it's important to include
information about the particular machines where the issues happen.
On the Jenkins job page of the failed CI build where the infrastructure
is reported in the logs (not to be confused with the parent build that
trigger the sub build that has the issues), on the top-right
corner, there is normally a line similar to
`Took 16 sec on test-equinix-ubuntu2004_container-armv7l-1`.
In this case, `test-equinix-ubuntu2004_container-armv7l-1`
is the machine having infrastructure issues, and it's important
to include this information in the report.

## TODO

- [ ] Read the flake database in ncu-ci so people can quickly tell if
      a failure is a flake
- [ ] Automate the report process in ncu-ci
- [ ] Migrate existing issues in nodejs/node and nodejs/build, close outdated
      ones.
