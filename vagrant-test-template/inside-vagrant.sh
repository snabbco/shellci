#!/bin/bash
set -e

echo -n "$(date '+%F %T') Started " > /vagrant/progress.txt

# Install software prerequisites
echo -n "$(date '+%F %T') apt-get.. " >> /vagrant/progress.txt
sudo apt-get install -q -y git
echo "ok"             >> /vagrant/progress.txt

# Install and run devstack
echo -n "$(date '+%F %T') devstack.. " >> /vagrant/progress.txt
cd $HOME
git clone https://github.com/openstack-dev/devstack.git
cd devstack
cp /vagrant/local.conf .
./stack.sh
echo "ok" >> /vagrant/progress.txt

# Install and run tempest                                                                                                             
echo -n "$(date '+%F %T') tempest.. " >> /vagrant/progress.txt
#cd $HOME
#git clone git://git.openstack.org/openstack/tempest.git
#cd tempest
#sudo python ./setup.py install
cd /opt/stack/tempest
testr init
testr run tempest.api.network.test_networks | tee /vagrant/tempest.log
if grep PASSED /vagrant/tempest.log; then
    echo "passed" >> /vagrant/progress.txt
else
    echo "failed" >> /vagrant/progress.txt
fi

# That's it                                                                                                                           
echo "$(date '+%F %T') Finished" >> /vagrant/progress.txt
