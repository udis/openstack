#!/bin/bash

##############################################################################################################################
# Prerequisites: yum install -y git
# Usage: ./install_director.sh
# 
# Description:
# This will install RHEL-OSP-Director undercloud and will deploy the overcloud using the docs commands and step by step
# GitHub: 
# https://github.com/udis/openstack.git
##############################################################################################################################

# This will read user input for virtual environment and overcloud customization
echo "Please Enter Number of Virtual Nodes NOT Including the Instack: "
read NODE_COUNT
echo "Please Enter Number of CPU per Node: "
read NODE_CPU 
echo "Please Enter Memory Size in MB per Node: "
read NODE_MEM
echo "Please Enter Number of Controller Nodes: "
read ctrlrs
echo "Please Enter Number of Compute Nodes: "
read computes
echo "Please Enter Number of Ceph Nodes: "
read cephs
  
#Create stack user on baremetal
sudo useradd stack
echo "Please enter a password for user stack: "
sudo passwd stack
echo "stack ALL=(root) NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/stack
sudo chmod 0440 /etc/sudoers.d/stack

#change permissions and copy script to stack user
chown stack:stack environment_setup.sh
chmod 755 environment_setup.sh
cp -p environment_setup.sh /home/stack

# Start virtual environment creation
sudo -H -u stack bash -c "cd && ./environment_setup.sh >> /tmp/environment_setup.log"

while [ -f /tmp/env_setup ]; do
t=$((t+10))
sleep 10
echo -ne "\rInstalling Virtual Environment... $t seconds passed"
done

# Get instack IP
instack_ip=`perl -nle 'print "$2" while (/(ssh root\@)([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})/g)' /home/stack/.instack/virt-setup.log`

# Copy and run undercloud installation
sudo chown stack:stack undercloud_installation.sh
chmod 755 undercloud_installation.sh
sudo -H -u stack bash -c "scp -p -o StrictHostKeyChecking=no undercloud_installation.sh root@${instack_ip}:/home/stack/"
sudo -H -u stack bash -c "ssh -o StrictHostKeyChecking=no root@${instack_ip} 'sudo -H -u stack bash -c \"cd && ./undercloud_installation.sh\"'"

# Copy and run overcloud installation


