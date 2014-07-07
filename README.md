# shellci

### OpenStack 3rd party CI in 100 lines of shell

*BRAND NEW WORK. IN PROGRESS. MAYBE ALREADY OVER CODE BUDGET*

shellci is a minimalist [3rd Party CI](http://ci.openstack.org/third_party.html) system. The design goals are:

1. Comply with OpenStack's official 3rd party CI rules.
2. Be a simple shell script that you can read and understand.
3. Capture all state in plain text files that you can see and correct.

shellci is supposed to be simple enough that you can feel responsible
for the operation of your installation.

### What shellci looks like

The `log/activity.log` from a healthy running shellci looks something like this:

```
d130e688 EVENT  https://review.openstack.org/93398
d130e688 TEST   openstack-dev/sandbox refs/changes/64/105064/2
d130e688 DONE   PASSED: Test ran successfully (100)
d130e688 VOTE   +1 https://review.openstack.org/93398
...
479a8ac2 EVENT  https://review.openstack.org/103291
479a8ac2 TEST   openstack-dev/sandbox refs/changes/63/105063/1
479a8ac2 DONE   HAZARD: Test exited with unrecognized status (none)
479a8ac2 VOTE   0 https://review.openstack.org/103291
...
97dfae69 EVENT  https://review.openstack.org/104917
97dfae69 TEST   openstack/sahara refs/changes/17/104917/1
97dfae69 DONE   FAILED: Test failed with cause (101)
97dfae69 VOTE   -1 https://review.openstack.org/104917
```

### How to start and stop shellci

shellci is started with a number of parallel ([sharded](http://en.wikipedia.org/wiki/Shard_(database_architecture))) test processes:

```
$ ./start 4
Starting gerrit-stream
Starting shard0
Starting shard1
Starting shard2
Starting shard3
```

Process `gerrit-stream` monitors `review.openstack.org` for events that should trigger builds. Process `shard <n>` polls for new events that hash onto a particular shard and tests them.

The processes are all logging into `log/` and the builds are being
executed in `tests/` (with logs retained for future reference).

When you have had enough you stop the processes (and stop them *hard*
to avoid leaving dangling Vagrants):

```
$ ./stop
Killing all VirtualBoxes (-TERM)
Killing all VirtualBoxes (-KILL)
Deleting all VirtualBoxes
```

### How to configure shellci

First you edit [`config`](config) to suit your driver, for example:

```shell
export CI_PROJECT=openstack-dev/sandbox
export CI_URL=http://snabb.co/ci/openstack/snabb-nfv-ci
export CI_ENABLE_VOTING=yes
export CI_TEST_CASE=${CI}/vagrant-test-template
```

That example uses the [`vagrant-test-template`](vagrant-test-template)
to test changes. The template fires up a Vagrant virtual machine,
installs [devstack](http://devstack.org), runs basic tempest tests,
then exits with a special status code for shellci (100=PASS, 101=FAIL,
other=WTF?). The script will vote +1 when tempest passes, -1 when
tempest detects failure, and otherwise 0 (for example if tempest fails
to run at all for some reason).

You can either customize the provided Vagrant example or replace it
entirely.

### How shellci state is stored on disk

shellci works by creating a series of files for each change that needs review:

1. `tests/<date>/<uuid>/event.json` is created by the [`gerrit-stream`](gerrit-stream) script for each published changeset that should be tested and reviewed.
2. `tests/<date>/<uuid>/test-result.txt` is created by the [`test-run`](test-run) script based on whether the change is found to work.
3. `tests/<date>/<uuid>/cast-votes.txt` is created by the [`vote`](vote) script when it casts a vote on the review server. The vote and review text are based on the contents of `test-result.txt`.

### The messy details

You want to really try shellci? Great! Here is what you should know:

shellci was initially developed and tested on Ubuntu 14.04.

You can play around with `shellci` using the same account as your real CI. If you don't set `CI_ENABLE_VOTING=yes` then no votes will be cast.

Create a new user (e.g. `ci`) and setup your SSH config so that it can connect to `review.openstack.org` without a password. You probably need to create `~/.ssh/config` with `User` and `IdentifyFile` items. If you have done it right then it should be possible to: `ssh -p 29418 review.openstack.org` without being prompted for a password.

You need to `apt-get install vagrant virtualbox`.

By default you need a Vagrant box called `ubuntu-trusty-for-ci` and ideally this will be preinstalled with a bunch of software that devstack needs (and, crucially, have mysql root password set to `password`). Here is how that is created:

```shell
# Define a vagrant based on Ubuntu (e.g. 14.04).
host$ vagrant init  # edit Vagrantfile to at least select the base box
# Create the vagrant
host$ vagrant up
# Login to the vagrant
host$ vagrant ssh
# Install software. (Important: set the MySQL root password to 'password')
vagrant$ apt-get --assume-yes install bridge-utils pylint python-setuptools screen unzip wget psmisc gcc git lsof openssh-server openssl python-virtualenv python-unittest2 iputils-ping wget curl tcpdump euca2ools tar python-dev python2.7 bc libyaml-dev libffi-dev libxml2-dev python-eventlet python-routes python-greenlet python-sqlalchemy python-wsgiref python-pastedeploy python-xattr python-iso8601 python-lxml python-pastescript python-pastedeploy python-paste sqlite3 python-pysqlite2 python-sqlalchemy python-mysqldb python-webob python-greenlet python-routes libldap2-dev libsasl2-dev libkrb5-dev python-dateutil msgpack-python fping dnsmasq-base dnsmasq-utils kpartx parted iputils-arping python-mysqldb python-xattr python-lxml gawk iptables ebtables sqlite3 sudo pm-utils libjs-jquery-tablesorter vlan curl genisoimage socat python-mox python-paste python-migrate python-greenlet python-libxml2 python-routes python-numpy python-pastedeploy python-eventlet python-cheetah python-tempita python-sqlalchemy python-suds python-lockfile python-m2crypto python-boto python-kombu python-feedparser python-iso8601 lvm2 open-iscsi genisoimage sysfsutils sg3-utils python-numpy tgt lvm2 qemu-utils libpq-dev open-iscsi python-beautifulsoup python-dateutil python-paste python-pastedeploy python-anyjson python-routes python-xattr python-sqlalchemy python-webob python-kombu pylint python-eventlet python-nose python-sphinx python-mox python-kombu python-coverage python-cherrypy3 python-migrate libxslt1-dev python-pip rabbitmq-server mysql-server qemu-kvm libvirt-bin python-libvirt python-guestfs apache2 libapache2-mod-wsgi
# Logout back to host
vagrant$ exit
# Snapshot the guest into ./package.box
host$ vagrant package
# Import for future use by shellci
host$ vagrant box add ubuntu-trusty-for-ci ./package.box
```
