# shellci: OpenStack 3rd party CI in 100 lines of shell

**BRAND NEW WORK IN PROGRESS**

This is a minimalist CI that is optimized to be easy for the operator
to understand and feel responsible for. There are no complex moving
parts like Jenkins, Gerrit Trigger Plugin, Zuul, Gearman, or
Nodepool. It's just a collection of short shell scripts.

Scripts:

* [`config.sh`](blob/master/config.sh) The whole configuration in one shell file.
* [`gerrit-stream`](blob/master/gerrit-stream) Fetch events from Gerrit on review.openstack.org.
* [`filter-events`](blob/master/filter-events) Choose the events that should trigger a build.
* `test-run` Execute a test run and determine a result.
* [`vote`](blob/master/vote) Cast a vote to the review server.
* `runme` Top-level script to run all of the above.

Directory structure:

* `event-firehose/<uuid>` pre-filtered events from Gerrit (one JSON event per file). Events are deleted after filtering.
* `event-queue/<uuid>` filtered events that should trigger a test. Events are deleted after test.
* `test-runs/<uuid>/` results of a test run including logs. Kept for 90 days.

You can serve up your whole shellci/ directory by WWW. Then everybody
can see your logs, configuration, event queue, and so on. They can
learn from your setup and maybe even tell you about problems they see.

