#!/usr/bin/env bash

# Brief: Deploy registrar and spire on separate node

# Details
# Deploy spire-server cluster2
# Change spire-agent server_address and server port based on the spire-server-0 
# Change registrar server_address and server port based on the spire-server-0 
# Generate token and update spire-agent manifest
# Deploy CRD, spire-agent, registrar cluster1

function pause_echo {

echo $@
sleep 3

}

main() {

  local -r dirname="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  local -r filename="${dirname}/$(basename "${BASH_SOURCE[0]}")"
  
  "${dirname}"/2-cleanup.sh > /dev/null
  
  pause_echo "# Deploy spire-server and cilium cluster2"

  kubectx cluster2
  kubectl apply -f spire-server.yaml
  kubectl get pods -A
  while [[ $(kubectl -n spire get pods spire-server-0 -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for pod" && sleep 1 && kubectl get pods -A; done

  pause_echo "# Change spire-agent server_address and server port based on the spire-server-0"
  current_server_ip=$(grep "server_address = " spire-agent.yaml  | awk -F\" '{print $2}')
  desired_server_ip=$(minikube service --url spire-server -p cluster2 -n spire | cut -d':' -f 2 | cut -b 3-)
  sed -i 's@'"${current_server_ip}"'@'"${desired_server_ip}"'@' spire-agent.yaml 
  current_server_port=$(grep "server_port = " spire-agent.yaml  | awk -F\" '{print $2}')
  desired_server_port=$(minikube service --url spire-server -p cluster2 -n spire | cut -d':' -f 3)
  sed -i 's@'"${current_server_port}"'@'"${desired_server_port}"'@' spire-agent.yaml 

  pause_echo "# Change registrar server_address and server port based on the spire-server-0"
  current_full_server_address=$(grep "server_address = " registrar.yaml  | awk -F\" '{print $2}')
  desired_full_server_address="${desired_server_ip}":"${desired_server_port}"
  sed -i 's@'"${current_full_server_address}"'@'"${desired_full_server_address}"'@' registrar.yaml
  echo $current_full_server_address
  echo $desired_full_server_address

  pause_echo "# Generate token and update spire-agent manifest"
  current_token=$(grep "join_token = " spire-agent.yaml  | awk -F\" '{print $2}')
  echo "########## CURRENT TOKEN ########## "
  echo "${current_token}"
  desired_token=$(kubectl exec -n spire pod/spire-server-0 -- ./bin/spire-server token generate -spiffeID spiffe://example.org/spire-agent | grep Token | cut -d' ' -f2)
  echo "########## DESIRED TOKEN ##########"
  echo "${desired_token}"
  sed -i 's@'"${current_token}"'@'"${desired_token}"'@' spire-agent.yaml 

  pause_echo "# Add privileged registration entry for the registrar"
  kubectl exec -n spire spire-server-0 -- \
    /opt/spire/bin/spire-server entry create \
    -spiffeID spiffe://example.org/registrar \
    -parentID spiffe://example.org/spire/agent/join_token/"${desired_token}" \
    -selector k8s:pod-label:app:spire-server \
    -selector unix:uid:0 \
    -admin

  pause_echo "# Deploy CRD, spire-agent, registrar cluster1"
  kubectx cluster1
  kubectl apply -f spiffeid.spiffe.io_spiffeids.yaml
  kubectl apply -f spire-agent.yaml
  kubectl apply -f registrar.yaml
  while [[ $(kubectl -n spire get pods spire-server-0 -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for pod" && sleep 1 && kubectl get pods -A; done

  kubectl apply -f https://raw.githubusercontent.com/kubernetes/website/master/content/en/examples/application/simple_deployment.yaml
  kubectl patch deployment nginx-deployment -p '{"spec":{"template":{"metadata":{"labels":{"spiffe.io/spiffe-id": "true"}}}}}'

  exit 0
}

main "$@"
