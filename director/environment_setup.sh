#!/bin/bash
cd ~
LOG=/home/stack/director-installation_`date +%d-%m-%y`.log
#Enable repos
sudo rpm -ivh http://rhos-release.virt.bos.redhat.com/repos/rhos-release/rhos-release-latest.noarch.rpm
sudo rhos-release 7-director
sudo yum install -y yum-utils
sudo yum-config-manager --enable rhelosp-rhel-7-server-opt

#Install instack undercloud
sudo yum install -y instack-undercloud

#Downloading image for setup your virtual environment - for TLV guys
IMAGE=http://10.35.7.52/rhel-guest-image/7.1/20150224.0/images/rhel-guest-image-7.1-20150224.0.x86_64.qcow2
#Downloading image for setup your virtual environment - for all other
#IMAGE=http://download.devel.redhat.com/brewroot/packages/rhel-guest-image/7.1/20150224.0/images/rhel-guest-image-7.1-20150224.0.x86_64.qcow2
curl -O \$IMAGE
export DIB_LOCAL_IMAGE=\`basename \$IMAGE\`
export DIB_YUM_REPO_CONF="/etc/yum.repos.d/rhos-release-7-director-rhel-7.1.repo /etc/yum.repos.d/rhos-release-7-rhel-7.1.repo"

#Costumize your VMs properties
export NODE_COUNT=4
export NODE_CPU=2
export NODE_MEM=5120

#start bulding your virtual environment
instack-virt-setup >> \$LOG

#show you VMs
sudo /usr/bin/virsh list --all

#Get instack IP
instack_ip=\`perl -nle 'print "\$2" while (/(ssh root\\@)([0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3})/g)' /home/stack/.instack/virt-setup.log \`
