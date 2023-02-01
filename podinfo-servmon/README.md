# podinfo-servmon: slack-receiver secret config

- Get a **slack-webhook-url** as per instructions from 
  https://grafana.com/blog/2020/02/25/step-by-step-guide-to-setting-up-prometheus-alertmanager-with-slack-pagerduty-and-gmail/#how-to-set-up-slack-alerts

- store slack-webhook-url in a k8s secret, that alertmanagerconfig will latter use
  ```
  cat <<'EOT' > create.secret.slack-receiver.sh
  kubectl create secret generic -n podinfo-servmon slack-receiver --from-literal=apiURL=https://hooks.slack.com/services/xxxx/yyyy/zzzzzzzzz
  EOT
  ```
  NOTE: `create.secret.slack-receiver.sh` is gitignore'd

- With this configuration done we can create a new cluster which will launch the podinfo-servmon configuration (including the secret) `cd .. && ./0.newClusterKubePromStack.sh`

