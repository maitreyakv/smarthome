up: init
  cd infra && \
    pulumi up

init:
  cd infra && \
    pulumi login file://. && \
    pulumi stack select main
