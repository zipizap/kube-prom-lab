# kube-prom-lab
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
