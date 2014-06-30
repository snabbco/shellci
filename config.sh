#!/usr/bin/env bash

# Set these values, either here in this file or in your environment.
CI_SSH_USER=${SSH_USER?}	# CI_SSH_USER=myciaccount
CI_SSH_OPTS=${SSH_OPTS?}	# CI_SSH_OPTS=-i $HOME/my_id_rsa
CI_DIR=${CI_DIR?}		# CI_DIR=$HOME/ci
CI_PROJECT=${CI_PROJECT?}	# CI_PROJECT=openstack-dev/sandbox
CI_URL=${CI_URL?}               # CI_URL=http://test.ci.com/home/ci/shellci/
CI_DEVSTACK=${CI_DEVSTACK}	# CI_DEVSTACK=script-that-runs-devstack
CI_TEMPEST=${CI_TEMPEST}        # CI_TEMPEST=script-that-runs-tempest
CI_INSTANCE=${CI_INSTANCE:1/1}	# CI_INSTANCE=3/10  (build server #3 of 10)

# Derived values

# Dir for new Gerrit events that are not yet filtered.
NEW_EVENTS=${CI_DIR?}/new-events
# Dir containing events that should trigger builds.
QUEUED_EVENTS=${CI_DIR?}/queued-events
# Dir for events that were skipped (optional)
SKIPPED_EVENTS=
# Dir for test runs. Contains the logs and can be served directly on www.
TESTS=${CI_DIR?}/test-runs

CI_CONFIGURED=yes

