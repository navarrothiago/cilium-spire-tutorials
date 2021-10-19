#!/usr/bin/env bash
main() {

  set -o errexit
  set -o pipefail
  set -o nounset

  local -r __dirname="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  local -r __filename="${__dirname}/$(basename "${BASH_SOURCE[0]}")"

  date=$(date '+%Y-%m-%d-%H%M%S')
  for i in {1..20}; do
    ./1-deploy.sh  
    # Sleep random 1, 2, 3, 4
    ran=$[ ( $RANDOM % 5 ) ]
    sleep "${ran}"s
    echo "======= $i times ========" > logs-${date}-loop.txt
    echo "sleep time: ${ran}"
    kubectl exec spire-server-0 -n spire -c spire-server --context cluster2 -- ./bin/spire-server entry show >> logs-${date}-loop.txt
  done

  exit 0
}
main "$@"
