# shellci

### OpenStack 3rd party CI in 100 lines of shell

*BRAND NEW WORK IN PROGRESS*

shellci is a minimalist [3rd Party CI](http://ci.openstack.org/third_party.html) system. The design goals are:

1. Comply with OpenStack's official 3rd party CI rules.
2. Be a simple shell script that you can read and understand.
3. Capture all state in plain text files that you can see and correct.

shellci is supposed to be simple enough that you can feel responsible
for the operation of your installation.

### How it works

shellci works by creating a series of files for each change that needs review:

1. `test-runs/<uuid>/event.json` is created by the [`gerrit-stream`](gerrit-stream) script for each published changeset that should be tested and reviewed.
2. `test-runs/<uuid>/test-result.txt` is created by the [`test-run`](test-run) script based on whether the change is found to work.
3. `test-runs/<uuid>/cast-votes.txt` is created by the [`vote`](vote) script when it casts a vote on the review server. The vote and review text are based on the contents of `test-result.txt`.

Ordinarily `gerrit-review` will run continuously in the background to
collect events and then [`run-tests`](run-tests) will be run
periodically to test and review any new changes. The operator is also
able to run the scripts manually, for example to correct a wrong
review.

### Setup

1. [`driver-config`](driver-config) is the configuration you write for your driver.
2. [`standard-config`](standard-config) can be referenced to see what configuration is available and required.

Then you need to run `gerrit-stream` to collect events and, periodically, `run-tests` to execute tests and post results.

### Example

Here is a fragment from the [shellci.log](http://egg.snabb.co:81/shellci/shellci.log) file:

```
66fd7174-6082-4ea3-8daf-8395cac43f0e IGNORE openstack-dev/sandbox https://review.openstack.org/99061
df21a1f5-45de-422e-91dc-59df4c325709 EVENT  https://review.openstack.org/99061
df21a1f5-45de-422e-91dc-59df4c325709 TEST   commit 845b0669ffb450a7c7577f4fe84c8b9367820c68
df21a1f5-45de-422e-91dc-59df4c325709 DONE   PASSED: Test ran successfully (100)
df21a1f5-45de-422e-91dc-59df4c325709 VOTE   +1 https://review.openstack.org/99061
```

The first two messages are printed by [`gerrit-stream`](gerrit-stream)
when it receives events from the OpenStack review event stream:

* `IGNORE` means an event was received but does not require action.
* `EVENT` means an event was received and should trigger a build. The event is stored in `test-runs/<UUID>/event.json`.

The next messages are printed by the [`test-run`](test-run) script
that executes a test run:

* `TEST` means a test run has started in a `test-runs/<UUID>/` directory.
* `DONE` means a test run has completed. The status is based on the exit code of testing script:
    * `PASSED`: the proposed change was tested successfully. (Exit code 100.)
    * `FAILED`: the proposed change was found to be bad. (Exit code 101.)
    * `SKIPPED`: the script declined to run a test. (Exit code 102.)
    * `REVIEW`: the test results should be reviewed by a human before voting. (Exit code 103.)
    * `HAZARD`: the test did not produce any of the above outcomes. (Any other exit code.)

The final message is printed by the [`vote`](vote) script that casts
votes to the review server.

* `VOTE` means a vote was cast to the review server.

