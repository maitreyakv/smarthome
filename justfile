
up: init 
  cd infra && pulumi up

refresh: init
  cd infra && pulumi refresh

stack: init
  cd infra && pulumi stack

init:
  cd infra && \
    pulumi login file://. && \
    pulumi stack select main

k9s:
  k9s --kubeconfig infra/.kube/config

kubeconfig:
  cd infra && mkdir -p .kube && \
    ssh $RPI_USER@$RPI_IP "sudo cat /etc/rancher/k3s/k3s.yaml" | sed -r "s/127.0.0.1/$RPI_IP/" \
    > .kube/config
