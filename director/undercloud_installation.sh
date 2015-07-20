#!/bin/bash
cd /home/stack/
sudo rpm -ivh http://rhos-release.virt.bos.redhat.com/repos/rhos-release/rhos-release-latest.noarch.rpm
sudo rhos-release 7-director
sudo yum install -y python-rdomanager-oscplugin
openstack undercloud install
sudo yum update -y
