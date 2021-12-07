#!/bin/bash -eux

KEYPAIR=bastion
FLAVOR=m1.large
IMAGE=ubuntu
NETWORK=network
INSTANCES_PER_COMPUTE=32
SMARTNIC_ENABLED="true"
PREFIX=fnord

# To allow for consistent placement of instances accross computes, we request
# specific hosts when creating the instances.  This is useful for consistent
# benchmarking and debugging during development.
COMPUTES="
    node-amontons.maas
"
for n in $(seq 1 $INSTANCES_PER_COMPUTE); do
    for c in $COMPUTES; do
        _c_short=$(echo $c|cut -f1 -d\.)
        if [ -n "$SMARTNIC_ENABLED" ]; then
            _port_name="smartnic_port_${_c_short}_${n}"
            openstack port create \
                --network $NETWORK \
                --vnic-type smart-nic \
                $_port_name
            _osc_port_arg="--nic port-id=$_port_name"
        else
            _osc_port_arg="--network $NETWORK"
        fi
        openstack server create \
             --key-name $KEYPAIR \
             --flavor $FLAVOR \
             --image $IMAGE \
	     --config-drive True \
             $_osc_port_arg \
             --os-compute-api-version 2.87 \
             --host $c \
          ${PREFIX}-${_c_short}-${n} &
    done
    wait
done
