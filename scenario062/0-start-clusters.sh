#!/usr/bin/env bash
main() {
  minikube delete -p cluster1

  # Cluster1 with CNI (cilium)
  minikube start --bootstrapper=kubeadm --memory 4096 --cpus 4 --profile cluster1 --network-plugin=cni
  minikube ssh -p cluster1 -- sudo mount bpffs -t bpf /sys/fs/bpf
  exit 0
}
main "$@"
