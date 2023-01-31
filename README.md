# kube-prom-lab

This is not working - probably because the prometheus-serviceaccount is missing additional permitions, and maybe there will then appear other issues - will look into kube-prometheus-stack

References:

- https://prometheus-operator.dev/
- https://prometheus-operator.dev/docs/user-guides/getting-started/
- https://prometheus-operator.dev/docs/user-guides/alerting/
- https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md
- https://blog.container-solutions.com/prometheus-operator-beginners-guide


# Start lab
```
./0.newClusterKubeprometheus.sh

```

# Manually scrap metrics from a target

Inside a nginx-controller pod `curl http://10.244.0.15:9093/metrics | less`

Many more targets from prometheus-web, targets section :)


# Finish lab
```
./9.deleteCluster.sh

```
