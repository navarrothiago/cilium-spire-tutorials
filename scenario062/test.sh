#!/usr/bin/env bash
main() {

  set -o errexit
  set -o pipefail
  set -o nounset

  local -r dirname="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  kubectl apply -f "${dirname}"/../cilium.yaml
  kubectl apply -f spiffeid.spiffe.io_spiffeids.yaml -f spire-agent.yaml -f spire-server-registrar.yaml
  while [[ $(kubectl -n spire get pods spire-server-0 -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for pod" && sleep 4 && kubectl get pods -A; done

  exit 0
}
main "$@"
