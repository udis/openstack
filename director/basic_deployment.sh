#!/bin/bash

source stackrc

curl -O http://10.35.7.52/mburns/latest-images/deploy-ramdisk-ironic.tar
curl -O http://10.35.7.52/mburns/latest-images/discovery-ramdisk.tar
curl -O http://10.35.7.52/mburns/latest-images/overcloud-full.tar

for i in `ls *.tar`;do tar xvf $i;done

openstack overcloud image upload
openstack baremetal import --json instackenv.json
openstack baremetal configure boot
openstack baremetal introspection bulk start
openstack flavor create --id auto --ram 5120 --disk 40 --vcpus 2 baremetal
openstack flavor set --property "cpu_arch"="x86_64" --property "capabilities:boot_option"="local" baremetal
puid=`openstack management plan list | grep overcloud | awk '{print $2}'`
openstack overcloud deploy --plan-uuid $puid  --control-scale 1 --compute-scale 2 --ceph-storage-scale 1 --block-storage-scale 0 --swift-storage-scale 0


