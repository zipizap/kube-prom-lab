#!/usr/bin/env bash

# USAGE
#   $0
#   $0 myns

watch kubectl -n ${1:-podinfo-servmon} get pod,deploy,service,servicemonitors,podmonitors,prometheusrules,alertmanagerconfigs
