#!/bin/sh

set -x

# Retrieve IDs of our project and default security group
PROJECT_ID=$(openstack project list -f value -c ID \
	       --domain admin_domain)
SECGRP_ID=$(openstack security group list --project $PROJECT_ID \
    | awk '/default/{print$2}')

# Add security group rules to allow ICMP and SSH to our instances
openstack security group rule create --ethertype IPv4 $SECGRP_ID --egress
openstack security group rule create --ethertype IPv6 $SECGRP_ID --egress
openstack security group rule create --ethertype IPv4 $SECGRP_ID --ingress \
    --protocol icmp
openstack security group rule create --ethertype IPv6 $SECGRP_ID --ingress \
    --protocol icmp
openstack security group rule create --ethertype IPv4 $SECGRP_ID --ingress \
    --protocol tcp --dst-port 22:22
openstack security group rule create --ethertype IPv6 $SECGRP_ID --ingress \
    --protocol tcp --dst-port 22:22

openstack network create \
    network
openstack subnet create \
    --network network \
    --subnet-range 10.42.0.0/22 \
    subnet

openstack network create \
    --external \
    --provider-network-type flat \
    --provider-physical-network physnet1 \
    ext-net
openstack subnet create \
    --subnet-range 192.0.2.0/24 \
    --no-dhcp \
    --gateway 192.0.2.1 \
    --network ext-net \
    --allocation-pool start=192.0.2.20,end=192.0.2.90 \
    ext

openstack router create router
openstack router set --external-gateway ext-net router
openstack router add subnet router subnet

openstack flavor create --ram 512 --disk 8 --vcpus 1 m1.tiny
openstack flavor create --ram 512 --disk 8 --vcpus 2 m1.small
openstack flavor create --ram 512 --disk 8 --vcpus 4 m1.medium
openstack flavor create --ram 512 --disk 8 --vcpus 8 m1.large
openstack quota set \
    --cores 2000 \
    --instances 1000 \
    --ram 512000 \
    --ports 2000 \
    --secgroup-rules 4000 \
    $PROJECT_ID

openstack keypair create --public-key ~/.ssh/id_rsa.pub bastion
openstack image create \
    --container-format bare \
    --disk-format qcow2 \
    --file focal-server-cloudimg-amd64.img \
    ubuntu
