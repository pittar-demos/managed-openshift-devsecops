#!/bin/bash

apps=$(oc get ingresscontroller default -n openshift-ingress-operator -o jsonpath='{.status.domain}')

# Add DevSpace link.
echo "  href: https://devspaces.$apps#http://gitea.scm.svc.cluster.local:3000/developer/battle-rest-heroes/raw/branch/main/devfile.yaml" \
  >> console-links/battle-devspace.yaml

# Add DevSpace link.
echo "  href: https://gitea-scm.$apps" \
  >> console-links/scm-gitea.yaml

# Add Nexus link.
echo "  href: https://nexus-cicd-tools.$apps" \
  >> console-links/nexus.yaml

# Add SonarQube link.
echo "  href: https://sonarqube-cicd-tools.$apps" \
  >> console-links/sonarqube.yaml

# Add Dev GitOps link.
echo "  href: https://argocd-server-developer-gitops.$apps" \
  >> console-links/developer-gitops.yaml

# Add Prod GitOps link.
echo "  href: https://argocd-server-production-gitops.$apps" \
  >> console-links/production-gitops.yaml

oc create -f console-links/battle-devspace.yaml
oc create -f console-links/scm-gitea.yaml
oc create -f console-links/nexus.yaml
oc create -f console-links/sonarqube.yaml
oc create -f console-links/developer-gitops.yaml
oc create -f console-links/production-gitops.yaml
