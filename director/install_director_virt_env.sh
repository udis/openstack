#!/bin/bash

#This will install RHEL-OSP-Director undercloud and will deploy the overcloud using the docs commands and step by step

#Create stack user on baremetal
sudo useradd stack
echo "Please enter a password for user stack: "
sudo passwd stack
echo "stack ALL=(root) NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/stack
sudo chmod 0440 /etc/sudoers.d/stack

cat <<EOT >> environment_setup.sh
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
instack_ip=\`grep ssh \$LOG | awk -F"@" '{print $2}'\`

cat <<EOF >> undercloud_installation.sh
#!/bin/bash
cd /home/stack/
sudo rpm -ivh http://rhos-release.virt.bos.redhat.com/repos/rhos-release/rhos-release-latest.noarch.rpm
sudo rhos-release 7-director
sudo yum install -y python-rdomanager-oscplugin
openstack undercloud install
sudo yum update -y
exit
EOF

sudo chown stack:stack undercloud_installation.sh
chmod 755 undercloud_installation.sh
scp -p -o StrictHostKeyChecking=no undercloud_installation.sh root@\${instack_ip}:/home/stack/
ssh -o StrictHostKeyChecking=no root@\${instack_ip} "sudo -H -u stack bash -c '/home/stack/undercloud_installation.sh'"
exit
EOT

#change permissions and copy script to stack user
chown stack:stack environment_setup.sh
chmod 755 environment_setup.sh
cp -p environment_setup.sh /home/stack

#run script

sudo -H -u stack bash -c "/home/stack/environment_setup.sh"
