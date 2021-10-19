#!/usr/bin/env bash
main() {
  minikube delete -p cluster1
  minikube delete -p cluster2

  mkdir -p ~/.minikube/files/etc/ca-certificates/
  cp token.csv ~/.minikube/files/etc/ca-certificates/token.csv

  # Cluster1 with CNI (cilium)
  minikube start --bootstrapper=kubeadm --memory 4096 --cpus 4 --profile cluster1 --extra-config=apiserver.token-auth-file=/etc/ca-certificates/token.csv
  minikube start --bootstrapper=kubeadm --memory 4096 --cpus 4 --profile cluster2 --extra-config=apiserver.token-auth-file=/etc/ca-certificates/token.csv
  exit 0
}
main "$@"
