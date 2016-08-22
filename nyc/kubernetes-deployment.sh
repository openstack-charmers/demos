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


# TODO(wolsen) At this point in the current cloud, it has http_proxy
# and https_proxy requirements, which need to be configured on the
# bootstrap-docker service. It'd be great if this could be scripted
# as part of the deployment.
#
# Reach out to lazyPower and mbruzek to see if it might be acceptable
# to add http-proxy and https-proxy settings into the
# /etc/default/bootstrap-docker
