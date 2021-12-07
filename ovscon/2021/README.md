# 1. Deploy bundle

```bash
juju deploy ./bundle.yaml
```

# 2. Add PPA for in-flight patches to libvirt, OVN, OpenStack Neutron & Nova

```bash
for application in \
        nova-cloud-controller \
        ovn-central \
        neutron-api \
        nova-compute \
        nova-compute-untrusted; do \
    juju run --application $application '
        add-apt-repository ppa:fnordahl/smartnic-enablement;
        export DEBIAN_FRONTEND=noninteractive; apt -y upgrade'
done
```

# 3. Add `virtual-function-count` to host netplan configuration (MAAS RFE)

```bash
juju run --application nova-compute-untrusted "
    sed -i '/enp130s0f0:$/a \ \ \ \ \ \ \ \ \ \ \ \ virtual-function-count: 64' /etc/netplan/50-cloud-init.yaml;
    netplan apply"
```

# 4. Add BlueField2 SmartNIC using the Juju manual provider     (MAAS RFE)

```bash
juju add-machine ssh:ubuntu@192.0.2.113
```

# 5. Deploy OVN dedicated chassis charm to SmartNIC

```bash
juju deploy ./charms/ovn-dedicated-chassis \
    --to 2 --config source=cloud:focal-xena \
    --bind data=overlay-space

juju run --application ovn-dedicated-chassis '
    add-apt-repository ppa:fnordahl/smartnic-enablement;
    apt -y upgrade'

juju run --unit ovn-dedicated-chassis/0 '
    sudo ovs-vsctl set open-vswitch . external_ids:ovn-cms-options="board-serial-number=MTNNNNXMMMMM"
```

# 6. Unseal and configure Vault

```bash
virtualenv --python python3 zaza

zaza/bin/pip install \
    git+https://github.com/openstack-charmers/zaza.git

zaza/bin/pip install \
    git+https://github.com/openstack-charmers/zaza-openstack-tests.git

zaza/bin/functest-configure \
    -m default \
    -c zaza.openstack.charm_tests.vault.setup.auto_initialize
```

# 7. Perform post-deploy configuration of OpenStack

```bash
source ~/src/github.com/openstack-charmers/openstack-charm-testing/rcs/openrc

./post-deploy-config.sh
```

# 8. Boot an instance

```bash
./create-smartnic-instances.sh
```
