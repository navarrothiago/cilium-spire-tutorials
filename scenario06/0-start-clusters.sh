#!/usr/bin/env bash
main() {
  minikube delete -p cluster1
  minikube delete -p cluster2
  # minikube start --bootstrapper=kubeadm --vm-driver=virtualbox --memory 4096 --cpus 4 --profile cluster1 --network-plugin=cni
  minikube start --bootstrapper=kubeadm --memory 4096 --cpus 4 --profile cluster1 --network-plugin=cni
  minikube ssh -p cluster1 -- sudo mount bpffs -t bpf /sys/fs/bpf
  # minikube start --bootstrapper=kubeadm --vm-driver=virtualbox --memory 4096 --cpus 4 --profile cluster2 --network-plugin=cni
  minikube start --bootstrapper=kubeadm --memory 4096 --cpus 4 --profile cluster2 --network-plugin=cni
  minikube ssh -p cluster2 -- sudo mount bpffs -t bpf /sys/fs/bpf
  exit 0
}
main "$@"
