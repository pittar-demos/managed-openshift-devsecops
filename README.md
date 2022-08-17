# Red Hat OpenShift Service on AWS (ROSA) - DevOps Demo

## The Benefits of a Platform

ROSA is more than just "managed Kubernetes" - it's managed Red Hat OpenShift Container Platform!  

What does that mean?  It means you have a managed service that is jointly engineered and supported by Red Hat and AWS.  You get a ton of fully supported runtimes and languages (OpenJDK 8/11/17, .Net Core, PHP, Python, Go, etc...) a great Kubernetes-native Java framework (Quarkus), and a number of technologies to build out a standards-based open source platform (OpenShift Serverless / Knative, OpenShift Service Mesh / Istio/Kiali/Jaeger, OpenShift Pipelines / Tekton, OpenShift GitOps / Argo CD, and more!).

Instead of using your best resources to stitch a number of technologies and services together, OpenShift provides you with the underpinnings of a fantastic platform that you can use in AWS (ROSA) or in any data centre.  All of these great tools and technologies are tested, supported, and backed by Red Hat.  This means you can be confident knowing that when it's time to upgrade your ROSA cluster, the other technologies you rely on (Service Mesh, Serverless, GitOps, etc...) will continue to run nicely - and if there is an issue, you have Red Hat's award winning support to fall back on.

Although there's a long list of great components that are part of ROSA, this demo will concentrate on a modern DevOps pipeline.  If you would like to replicate this demo in your own ROSA cluster (or any OpenShift 4.10 cluster, for that matter), you can follow along with the install instructions to get up and running in just a couple of commands!

## Demo Setup

This demo is bootstrapped with Argo CD (OpenShift GitOps).  From the deployment of OpenShift Pipelines, creating the pipelines themseles, and rolling out the app... it's all done automatically!  Isn't GitOps great?

### Install OpenShift GitOps

The first step is to install the OpenShift GitOps operator in your cluster.  You can either do this through the embedded OperatorHub in the OpenShift Admin UI, or with the `oc` CLI.  For this demo, we'll stick to the CLI so we can use GitOps from top to bottom.

```
# Login a cluster admin.
oc login # As a cluster admin

# Deploy OpenShift GitOps Operator.
oc apply -k https://github.com/redhat-cop/gitops-catalog/openshift-gitops-operator/overlays/gitops-1.6

# Once OpenShift GitOps is deployed, patch the config to enable Dex and Edge Termintad route.
oc patch argocd openshift-gitops -n openshift-gitops \
  --type='merge' \
  --patch-file 00-setup/argocd-extended-config-patch.yaml 
```

In a moment, you will have your first instance of OpenShift GitOps (Argo CD) running in the `openshift-gitops` namespace.  You should also see a new link for "OpenShift GitOps" in the links menu of the OpenShift UI (the little "grid" icon near the top-right of the screen).

You can click on that link and login with your cluster admin credentials now if you like, but you don't need to quite yet if you're itching to deploy more stuff!

### Deploy an "App of Apps" for Cluster Config

The rest of the configuration will be done by Argo CD / OpenShift GitOps.  For this, we will create an Argo CD `Application` that references a git repository that contains the other Argo CD `Applications` that make up the different components of this demo.  This is a very common pattern to use in the world of Argo CD.

First, we will deploy the "App of Apps" responsible for cluster configuration:

```
oc apply -k 01-cluster-admin/01-argocd/01-clusters/nonprod/bootstrap
```

### Deploy an "App of Apps" for Developer Setup

Once the cluster is configured, it's time to bootstrap any applications, tools, or CI pipelines developers require.

```
oc apply -k 02-developers/01-argocd/01-clusters/nonprod/bootstrap
```