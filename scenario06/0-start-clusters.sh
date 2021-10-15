#!/usr/bin/env bash
main() {
  minikube delete -p cluster1
  minikube delete -p cluster2

  # Cluster1 with CNI (cilium)
  minikube start --bootstrapper=kubeadm --memory 8192 --cpus 4 --profile cluster1 --network-plugin=cni \
                --extra-config=apiserver.authorization-mode=Node,RBAC \
                --extra-config=apiserver.service-account-signing-key-file=/var/lib/minikube/certs/sa.key \
                --extra-config=apiserver.service-account-key-file=/var/lib/minikube/certs/sa.pub \
                --extra-config=apiserver.service-account-issuer=api \
                --extra-config=apiserver.service-account-api-audiences=api,spire-server
  minikube ssh -p cluster1 -- sudo mount bpffs -t bpf /sys/fs/bpf

  # Cluster2 without CNI 
  minikube start --bootstrapper=kubeadm --memory 8192 --cpus 4 --profile cluster2 \
                --extra-config=apiserver.authorization-mode=Node,RBAC \
                --extra-config=apiserver.service-account-signing-key-file=/var/lib/minikube/certs/sa.key \
                --extra-config=apiserver.service-account-key-file=/var/lib/minikube/certs/sa.pub \
                --extra-config=apiserver.service-account-issuer=api \
                --extra-config=apiserver.service-account-api-audiences=api,spire-server
  exit 0
}
main "$@"
