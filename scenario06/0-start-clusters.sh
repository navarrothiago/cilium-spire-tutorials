#!/usr/bin/env bash
main() {
  minikube delete -p cluster1
  minikube delete -p cluster2
  minikube start --bootstrapper=kubeadm --vm-driver=virtualbox --memory 4096 --cpus 4 --profile cluster1 
  minikube start --bootstrapper=kubeadm --vm-driver=virtualbox --memory 4096 --cpus 4 --profile cluster2 
  exit 0
}
main "$@"
