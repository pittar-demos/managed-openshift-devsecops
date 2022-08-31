#!/bin/bash

# Add DevSpace link.
echo "  href: https://devspaces."$(oc get ingresscontroller default -n openshift-ingress-operator -o jsonpath='{.status.domain}')"#http://gitea.scm.svc.cluster.local:3000/developer/battle-rest-heroes/raw/branch/main/devfile.yaml" \
  >> console-links/battle-devspace.yaml

oc create -f console-links/battle-devspace.yaml