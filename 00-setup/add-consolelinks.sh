#!/bin/bash

apps=$(oc get ingresscontroller default -n openshift-ingress-operator -o jsonpath='{.status.domain}')

# Add DevSpace link.
echo "  href: https://devspaces.$apps#http://gitea.scm.svc.cluster.local:3000/developer/battle-rest-heroes/raw/branch/main/devfile.yaml" \
  >> console-links/battle-devspace.yaml

# Add DevSpace link.
echo "  href: https://gitea-scm.$apps" \
  >> console-links/scm-gitea.yaml

oc create -f console-links/battle-devspace.yaml
oc create -f console-links/scm-gitea.yaml
