# kube-prom-lab

Using **kube-prometheus-stack**


# Quickrefs
## Start lab
```
./0.newClusterKubePromStack.sh

```
## Manually scrap metrics from a target

Inside a nginx-controller pod `curl http://10.244.0.15:9093/metrics | less`

Many more targets from prometheus-web, targets section :)

## Finish lab
```
./9.deleteCluster.sh

```


# NOTES

## label release: kube-prometheus-stack
ServiceMonitor,PodMonitor,Probe,PrometheusRule: need label `release: kube-prometheus-stack` to be picked up

```
❯ k get prometheus -Aoyaml | grep -C5 'release: kube-prometheus-stack'
    ...
    podMonitorNamespaceSelector: {}        << all namespaces
    podMonitorSelector:
      matchLabels:
        release: kube-prometheus-stack     << only the ones containing this label
    ...
    probeNamespaceSelector: {}
    probeSelector:
      matchLabels:
        release: kube-prometheus-stack
    ...
    ruleNamespaceSelector: {}
    ruleSelector:
      matchLabels:
        release: kube-prometheus-stack
    ...
    serviceMonitorNamespaceSelector: {}
    serviceMonitorSelector:
      matchLabels:
        release: kube-prometheus-stack
```

##
