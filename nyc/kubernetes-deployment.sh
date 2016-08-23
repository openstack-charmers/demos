#!/bin/bash
#
# This file is used to setup and install the observable-kubernetes
# juju bundle in an environment requiring and http(s) proxy.
#

set -ex


# First, let's create the model which will run the kubernetes bundle
juju add-model --config kube-model.yaml kubernetes

# Next, deploy the observable-kubernetes bundle
juju deploy observable-kubernetes

