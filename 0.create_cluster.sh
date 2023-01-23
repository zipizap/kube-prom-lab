#!/usr/bin/env bash
set -xefu


# cr kind cluster with nginx-ingress 
cat <<EOF >KindClusterConfig.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: kind   #cluster name for "kind get cluster"
nodes:
#- role: control-plane|worker    (default is 1 control-plan)
- role: control-plane
  # K8s version to deploy (see  https://github.com/kubernetes-sigs/kind/releases)
  image: kindest/node:v1.24.7
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  # Ingress: expose k8s-ingress-ports (containerPort) into dockerhost-ports (hostPort)
  # dockerHost:10080 and 10443
  - containerPort: 80
    hostPort: 10080
    protocol: TCP
  - containerPort: 443
    hostPort: 10443
    protocol: TCP
EOF
# overwrites $KUBECONFIG or ~/.kube/config.yaml
kind create cluster \
  --wait 5m \
  --config KindClusterConfig.yaml
rm -f KindClusterConfig.yaml
# install nginx ingress
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s
cat <<EOT
#############################################
#  dockerHost:10080  -> k8s-ingress:80
#  dockerHost: 10443 -> k8s-ingress:443
#############################################
EOT

# save kubeconfig
kind get kubeconfig > kind.kubeconfig.yaml
source KUBECONFIG.source
