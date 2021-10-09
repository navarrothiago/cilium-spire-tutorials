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
  kubectl delete -f "${dirname}"/../cilium.yaml

  exit 0
}
main "$@"
