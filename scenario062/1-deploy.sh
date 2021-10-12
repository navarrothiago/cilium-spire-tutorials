#!/usr/bin/env bash

# Brief: Deploy cilium, registrar, spire and workload to separated clusters.

# Details
# Deploy spire-server cluster2
# Change spire-agent server_address and server port based on the spire-server-0 
# Change registrar server_address and server port based on the spire-server-0 
# Generate token and update spire-agent manifest
# Deploy CRD, spire-agent, registrar cluster1
# Deploy nginx

function pause_echo {

echo $@
# sleep 3

}

main() {

  local -r dirname="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  local -r filename="${dirname}/$(basename "${BASH_SOURCE[0]}")"
  
  "${dirname}"/2-cleanup.sh 2> /dev/null

 # TODO check admin flag. If remove, boomm! error:
 # unable to make Mint SVID Request: rpc error: code = PermissionDenied desc = authorization denied for method /spire.api.server.svid.v1.SVID/MintX509SVID
  container_id_cluster1=$(docker container ls | grep cluster1 | cut -d" " -f 1)

  pause_echo "# Deploy cilium, CRD, spire-agent, registrar to cluster1"
  kubectx cluster1
  kubectl apply -f "${dirname}/../"cilium.yaml
  kubectl apply -f spiffeid.spiffe.io_spiffeids.yaml
  kubectl apply -f spire-agent.yaml
  kubectl apply -f spire-server-registrar.yaml
  while [[ $(kubectl -n spire get pods spire-server-0 -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for pod" && sleep 4 && kubectl get pods -A; done

  kubectl exec -n spire spire-server-0 -- \
    /opt/spire/bin/spire-server entry create \
    -spiffeID spiffe://example.org/ciliumagent \
    -parentID spiffe://example.org/k8s-workload-registrar/demo-cluster/node/cluster1 \
    -selector unix:uid:0 
    # -admin

  pause_echo "# Deploy nginx workload to cluster1"
  kubectl apply -f https://raw.githubusercontent.com/kubernetes/website/master/content/en/examples/application/simple_deployment.yaml
  kubectl patch deployment nginx-deployment -p '{"spec":{"template":{"metadata":{"labels":{"spiffe.io/spiffe-id": "true"}}}}}'

  exit 0
}

main "$@"
