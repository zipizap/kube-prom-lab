#!/usr/bin/env bash
set -xefu

source_kubeconfig() {
  source KUBECONFIG.source
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
