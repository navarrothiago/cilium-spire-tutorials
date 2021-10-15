#!/usr/bin/env bash
main() {

  # set -o errexit
  # set -o pipefail
  # set -o nounset

  local -r dirname="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  # Clean up cluster1
  kubectx cluster1
  kubectl delete -f spiffeid.spiffe.io_spiffeids.yaml
  kubectl delete -f registrar.yaml
  kubectl delete -f spire-agent.yaml
  kubectl delete -f simple_deployment.yaml
  kubectl delete -f "${dirname}"/../cilium.yaml
 
  # Clean up cluster2
  kubectx cluster2
  kubectl delete -f spire-server.yaml

  container_id_cluster1=$(docker container ls | grep cluster1 | cut -d" " -f 1)
  container_id_cluster2=$(docker container ls | grep cluster2 | cut -d" " -f 1)

  # Disconnect bridges
  docker network disconnect cluster2 "${container_id_cluster1}"
  docker network disconnect cluster1 "${container_id_cluster2}"

  exit 0
}
main "$@"
