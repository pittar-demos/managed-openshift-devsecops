# Managed Red Hat OpenShift (ARO and ROSA) - DevSecOps Demo

## TL;DR - What's In This Demo?

* [Azure Red Hat OpenShift](https://azure.microsoft.com/en-us/products/openshift/#overview) or [Red Hat OpenShift Service on AWS - ROSA](https://aws.amazon.com/rosa/)
* OpenShift GitOps (Argo CD) - Supported and included with OpenShift!
* OpenShift Pipelines (Tekton) - Supported and included with OpenShift!
* Tekton Chains (supply chain security) - Tech Preview (supported soon with OpenShift)!
* OpenShift Dev Spaces (Eclipse Che) - Supported and included with OpenShift!
* Quarkus - Supported and included with OpenShift!
* Strimzi - Kubernetes-native Kafka (community upstream to Red Hat AMQ Streams)
* Apicurio - Schmea Registry (community upstream to Red Hat Schema Registry)
* PostgreSQL and MongoDB - Community supported containers (although supported PostgreSQL, MySQL and MariaDB container images come with OpenShift)
* **Everything As Code**

## Link to this Repo

Open your camera and take a look at this QR code.  It will link to this repo:

![Repository Link](images/qr.png)


## The Benefits of a Platform

ARO and ROSA are more than just "managed Kubernetes" - it's managed Red Hat OpenShift Container Platform!  

What does that mean?  It means you have a managed service that is jointly engineered and supported by Red Hat and AWS/Microsoft.  You get a ton of fully supported runtimes and languages (OpenJDK 8/11/17, .Net Core, PHP, Python, Go, etc...) a great Kubernetes-native Java framework (Quarkus), and a number of technologies to build out a standards-based open source platform (OpenShift Serverless / Knative, OpenShift Service Mesh / Istio/Kiali/Jaeger, OpenShift Pipelines / Tekton, OpenShift GitOps / Argo CD, and more!).

Instead of using your best people to stitch a number of technologies and services together for a "DIY" platform, OpenShift provides you with the underpinnings of a fantastic platform that you can use in AWS (ROSA), Microsoft Azure (ARO) or in any data centre.  All of these great tools and technologies are tested, supported, and backed by Red Hat.  This means you can be confident knowing that when it's time to upgrade your ARO or ROSA cluster, the other technologies you rely on (Service Mesh, Serverless, GitOps, etc...) will continue to run nicely - and if there is an issue, you have Red Hat's award winning support to get you back on track.

Although there's a long list of great components that are part of ARO and ROSA, this demo will concentrate on a modern DevOps pipeline.  If you would like to replicate this demo in your own AOR or ROSA cluster (or any OpenShift 4.10 cluster, for that matter), you can follow along with the install instructions to get up and running in just a couple of commands!

## Demo Concept

This demo is based on the official [Quarkus Super Heroes](https://quarkus.io/quarkus-workshops/super-heroes/) demo application.  This application consists of a number of Quarkus-based microservices as well as an AngularJS front end app.  State is stored in PostgreSQL databases, MongoDB, or Kafka.

Tracing has been left out of this particular demo to simplify the demo. 

This demo will fully "gitops" the Quarkus Super Heroes demo, using OpenShift GitOps (Argo CD) to manage environments and cluster configuration, as well as OpenShift Pipelines (Tekton) to build the various microservices and container images.  Tekton Chains (with cosign) will be used to sign the pipeline runs and resulting images to increase supply chain integrity.

OpenShift Dev Spaces will be used to provide a consistent and easy to access development environemnt hosted on the same OpenShift cluster.

## Demo Setup

This demo is bootstrapped with Argo CD (OpenShift GitOps).  From the deployment of OpenShift Pipelines, creating the pipelines themseles, and rolling out the app... it's all done automatically!  Isn't GitOps great?

This is the only git repository you need to clone.  Nice!

### Install OpenShift GitOps

The first step is to install the OpenShift GitOps operator in your cluster.  You can either do this through the embedded OperatorHub in the OpenShift Admin UI, or with the `oc` CLI.  For this demo, we'll stick to the CLI so we can use GitOps from top to bottom.

Login as a "cluster admin":
```
oc login # As a cluster admin
```

Deploy OpenShift GitOps Operator:
```
oc apply -k https://github.com/redhat-cop/gitops-catalog/openshift-gitops-operator/overlays/gitops-1.7
```

Wait for Argo CD to finish rolling out:
```
oc rollout status deploy openshift-gitops-server -n openshift-gitops
```

You will now have your first instance of OpenShift GitOps (Argo CD) running in the `openshift-gitops` namespace.  You should also see a new link for "OpenShift GitOps" in the links menu of the OpenShift UI (the little "grid" icon near the top-right of the screen).  Don't login quite yet, though... there is a bit more config to do first.

### Deploy an "App of Apps" for Cluster Config

The rest of the configuration will be done by Argo CD / OpenShift GitOps.  For this, we will create an Argo CD `Application` that references a git repository that contains the other Argo CD `Applications` that make up the different components of this demo.  This is a very common pattern to use in the world of Argo CD.

First, we will deploy the "App of Apps" responsible for cluster configuration:

```
oc apply -k 01-cluster-admin/01-argocd/01-clusters/nonprod/bootstrap
```

This step will take a while, as it is deploying and configuring a lot of core services, including:

* Sonatype Nexus
* SonarQube
* OpenShift Pipelines Operator
* OpenShift Dev Spaces Operator and Instance
* Gitea Operator and Instance
* Compliance Operator and "Moderate (NIST 800-53)" Scans
* User Workload Monitoring
* Grafana Operator and Instance
* Strimzi Operator
* Web Terminal Operator
* CICD, DEV and TEST namespaces for the "Quarkus Super Heroes" application.

You can watch the progress of these services being deployed by logging into the default Argo CD instance as a cluster admin.

If you notice the "Compliance" Application remains degraded, this is because the reports have not been generated.  You will need to manually start the `CronJob` the first time (it's set to run every day at 5am by default).

```
oc create job --from=cronjob/compile-compliance-report-cronjob initial-reports -n report-view
```

After 5-10 minutes, all applications should be "green" (with the exception of Compliance).  If they are not, you can try "refreshing" any application that is still "progressing", as it might simply be that Argo CD hasn't update the status of that application yet.

Once all apps (with the possible exception of "Compliance") are green, you can move on to the next step.

### Deploy an "App of Apps" for Developer Setup

Once the cluster is configured, it's time to bootstrap any applications, tools, or CI pipelines developers require.

```
oc apply -k 02-developers/01-argocd/01-clusters/nonprod/bootstrap
```

This step will take a while, as it is deploying and configuring a lot of developer namespaces, this inclues:

* OpenShift Pipelines in the "superhero-battle-cicd" namespace (under "Pipelines" side nav option)
* Initial pipeline runs.
* All Deployments, operator instances, PVCs, services, routes, etc... in "superhero-battle-dev" namespace.
* All Deployments, operator instances, PVCs, services, routes, etc... in "superhero-battle-test" namespace.

From the "Developer" OpenShift UI you can watch the progress of the initial builds by navigating to the "superher-battle-cicd" namespace and select "Pipelines" from the side navigation.  If a pipeline run fails, it might have been triggered before OpenShift Pipelines was fully configured.  If this is the case, simply select the failed pipeline run and select "Rerun" from the actions menu at the top-right of the screen.

Once the builds complete, you can see the resulting applications in the "supehero-battle-dev" and "superhero-battle-test" namespaces.

### Create Console Links

To make navigating the rest of the demo easier, run the following command to create console links in the OpenShift UI for the different tools we will use (Gitea, Nexus, SonarQube, Argo CD, etc...):
```
cd 00-setup/
./add-consolelinks.sh
```

### Deploy an "App of Apps" for Production Setup (not yet implemented)

**NOTE:** This section is not yet implemented.  Skip this for now.

Once the cluster is configured, it's time to bootstrap the "Production" environment (for the demo, we are still using the same cluster for simplicity).

```
oc apply -k 02-developers/01-argocd/01-clusters/prod/bootstrap
```
