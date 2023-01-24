#!/usr/bin/env bash
set -xefu
kubectl port-forward -n monitoring service/prometheus-k8s 9090:9090 &
PORTFWD_PROMETHEUS_PID=$!
kubectl port-forward -n monitoring service/alertmanager-main 9093:9093 &
PORTFWD_ALERTMANAGER_PID=$!
kubectl port-forward -n monitoring service/grafana 3000:3000 &
PORTFWD_GRAFANA_PID=$!

# prometheus
xdg-open http://localhost:9090 &>/dev/null
# alertmanager
xdg-open http://localhost:9093 &>/dev/null
# grafana
xdg-open http://localhost:3000 &>/dev/null

cat <<EOT
######################################################################
# + Prometheus     http://localhost:9090
# + Alertmanager   http://localhost:9093
# + Grafana        http://localhost:3000    login: admin // admin
# 
# Port-forwarding running in background. Terminate it manually with:
#   kill #9 $PORTFWD_PROMETHEUS_PID $PORTFWD_ALERTMANAGER_PID $PORTFWD_GRAFANA_PID
######################################################################
EOT
