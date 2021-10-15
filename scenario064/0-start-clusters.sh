#!/usr/bin/env bash
main() {
  minikube delete -p cluster1
  minikube delete -p cluster2

  # Cluster1 with CNI (cilium)
  minikube start --bootstrapper=kubeadm --memory 4096 --cpus 4 --profile cluster1 
  minikube start --bootstrapper=kubeadm --memory 4096 --cpus 4 --profile cluster2 
  exit 0
}
main "$@"
