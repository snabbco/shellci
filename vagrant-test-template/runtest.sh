#!/bin/bash
VM_ID=shellci${CI_SHARD}

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

echo "Destroying old VM with id ${VM_ID} (if it exists)"
vagrant destroy -f
vboxmanage controlvm ${VM_ID} poweroff
vboxmanage unregistervm ${VM_ID} --delete
vagrant destroy -f
echo "Starting VM with id ${VM_ID}"
vagrant up
echo "Destroying used vagrant"
vagrant destroy -f