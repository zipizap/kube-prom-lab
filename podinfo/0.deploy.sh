#!/usr/bin/env bash
set -xefu

# https://github.com/stefanprodan/podinfo/tree/master/charts/podinfo
#
# helm \
#   template `#upgrade --install` \
#   --create-namespace --namespace podinfo \
#   podinfo \
#   oci://ghcr.io/stefanprodan/charts/podinfo \
#   --set replicaCount=2 \
#   --set serviceMonitor.enabled=true 

kubectl apply -f podinfo.yaml
