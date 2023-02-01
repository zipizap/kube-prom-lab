#!/usr/bin/env bash
set -xefu

source_kubeconfig() {
  source KUBECONFIG.source
}

portfwd_in_background() {
  kubectl port-forward -n monitoring service/kube-prometheus-stack-prometheus 9090:9090 1>/dev/null &
  PORTFWD_PROMETHEUS_PID=$!
  kubectl port-forward -n monitoring service/kube-prometheus-stack-alertmanager 9093:9093 1>/dev/null &
  PORTFWD_ALERTMANAGER_PID=$!
  kubectl port-forward -n monitoring service/kube-prometheus-stack-grafana 3000:80 1>/dev/null &
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
# + Grafana        http://localhost:3000    login: admin // prom-operator
# 
# Port-forwarding running in background. Terminate it manually with:
#   kill -9 $PORTFWD_PROMETHEUS_PID $PORTFWD_ALERTMANAGER_PID $PORTFWD_GRAFANA_PID
#
#
######################################################################
EOT

}

main() {
  source_kubeconfig
  portfwd_in_background
}
main "${@}"
