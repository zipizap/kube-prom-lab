#!/usr/bin/env bash
set -xefu

create_cluster() {
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
    --timeout=240s
  cat <<EOT
#############################################
#  dockerHost:10080  -> k8s-ingress:80
#  dockerHost: 10443 -> k8s-ingress:443
#############################################
EOT

  # save kubeconfig
  kind get kubeconfig > kind.kubeconfig.yaml
  chmod 600 kind.kubeconfig.yaml
}

source_kubeconfig() {
  source KUBECONFIG.source
}

install_kubePromStack() {
  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
  helm repo update
  #wget https://github.com/prometheus-community/helm-charts/raw/kube-prometheus-stack-44.3.0/charts/kube-prometheus-stack/values.yaml 
  helm \
    upgrade --install \
    --create-namespace --namespace monitoring \
    --version 44.3.0 \
    -f ./kube-prometheus-stack.myvalues.yaml \
    kube-prometheus-stack prometheus-community/kube-prometheus-stack
  sleep 30
  kubectl wait -n monitoring -l statefulset.kubernetes.io/pod-name=prometheus-kube-prometheus-stack-prometheus-0 --for=condition=ready pod --timeout=5m
}

deploy_podinfoServmon() {
  cd podinfo-servmon 
  ./0.deploy.sh
  cd ..
}

main() {
  create_cluster
  source_kubeconfig
  install_kubePromStack

  deploy_podinfoServmon
  
  ./1.web.portfwd.PrometheusAlertmanagerGrafana.sh
  #./2.watch.resources.sh
}
main "${@}"
