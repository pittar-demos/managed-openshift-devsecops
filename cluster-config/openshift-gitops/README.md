# Cluster Config: OpenShift GitOps

This includes an "extended" cluster role for the cluster-wide Argo CD instance to allow for the creation of `ResourceQuota`, `LimitRange`, `SealedSecrets` and `ArgoCD` resources in all namespaces.