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
    --timeout=90s
  cat <<EOT
#############################################
#  dockerHost:10080  -> k8s-ingress:80
#  dockerHost: 10443 -> k8s-ingress:443
#############################################
EOT

  # save kubeconfig
  kind get kubeconfig > kind.kubeconfig.yaml
}

source_kubeconfig() {
  source KUBECONFIG.source
}

install_kubeprometheus() {
  # https://github.com/prometheus-operator/kube-prometheus#quickstart
  #
  # Create the namespace and CRDs, and then wait for them to be available before creating the remaining resources
  # Note that due to some CRD size we are using kubectl server-side apply feature which is generally available since kubernetes 1.22.
  # If you are using previous kubernetes versions this feature may not be available and you would need to use kubectl create instead.
  cd kube-prometheus
  kubectl apply --server-side -f manifests/setup
  kubectl wait \
    --for condition=Established \
    --all CustomResourceDefinition \
    --namespace=monitoring
  kubectl apply -f manifests/
  sleep 160
}

portfwd_in_background() {
  kubectl port-forward -n monitoring service/prometheus-k8s 9090:9090 1>/dev/null &
  PORTFWD_PROMETHEUS_PID=$!
  kubectl port-forward -n monitoring service/alertmanager-main 9093:9093 1>/dev/null &
  PORTFWD_ALERTMANAGER_PID=$!
  kubectl port-forward -n monitoring service/grafana 3000:3000 1>/dev/null &
  PORTFWD_GRAFANA_PID=$!

  # prometheus
  xdg-open http://localhost:9090 &>/dev/null
  # alertmanager
  xdg-open http://localhost:9093 &>/dev/null
  # grafana
  xdg-open http://localhost:3000 &>/dev/null

  cat <<EOT
######################################################################
### Webpages portforwarded
#
# + Prometheus     http://localhost:9090
# + Alertmanager   http://localhost:9093
# + Grafana        http://localhost:3000    login: admin // admin
# 
# Port-forwarding running in background. Terminate it manually with:
#   kill #9 $PORTFWD_PROMETHEUS_PID $PORTFWD_ALERTMANAGER_PID $PORTFWD_GRAFANA_PID
#
#
######################################################################
EOT

}

main() {
  create_cluster
  source_kubeconfig
  install_kubeprometheus
  portfwd_in_background
}
main "${@}"