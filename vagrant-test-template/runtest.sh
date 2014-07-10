#!/bin/bash
VM_ID=shellci${CI_SHARD}

trap "vagrant destroy -f; find . -type l -xtype l -exec rm {} +" EXIT

# Check out the version that should be tested.
# XXX Support all projects (?)
if [ -f event.json ]; then
    project=$(cat event.json | sed -z -e 's/.*"project": "//' -e 's/".*//')
    ref=$(cat event.json | sed -z -e 's/.*"ref": "//' -e 's/".*//')
    case "${project}" in
	openstack/neutron) neutron_branch=${ref};;
	openstack/nova)    nova_branch=${ref};;
	# etc...
    esac
fi
sed -e "s;%neutron_branch%;${neutron_branch:-master};" \
    -e "s;%nova_branch%;${nova_branch:-master};" \
    < local.conf.template > local.conf

echo "Destroying old vagrant (if one exists)"
vagrant destroy -f
echo "Starting VM with id ${VM_ID}"
vagrant up
# Set exit status as shellci expects it
grep -q PASSED tempest.log && exit 100
grep -q FAILED tempest.log && exit 101
