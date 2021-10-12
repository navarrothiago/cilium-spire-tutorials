#!/usr/bin/env bash
main() {

  set -o errexit
  set -o pipefail
  set -o nounset

  kubectl delete -f spiffeid.spiffe.io_spiffeids.yaml -f spire-agent.yaml -f spire-server-registrar.yaml

  exit 0
}
main "$@"
