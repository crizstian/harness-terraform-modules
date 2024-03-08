# [ TODO ] mcr.microsoft.com/vscode/devcontainers/alpine
# https://github.com/microsoft/vscode-dev-containers/tree/master/containers/alpine/.devcontainer
FROM golang:alpine
USER root
ENV GO111MODULE=on
ARG GOLANGCI_LINT_VERSION=v1.35.2
ARG GOPLS_VERSION=v0.6.4
ARG DELVE_VERSION=v1.5.0
ARG GOMODIFYTAGS_VERSION=v1.13.0
ARG GOPLAY_VERSION=v1.0.0
ARG GOTESTS_VERSION=v1.5.3
ARG STATICCHECK_VERSION=2020.2.1

RUN apk upgrade --no-cache && \
  apk add --no-cache --progress git build-base findutils make bat exa \
  coreutils wget curl aria2 bash ncurses binutils jq sudo ripgrep g++ \
  vault fuse-dev libcap neofetch docker docker-compose openssh py3-pip yq && \
  setcap cap_ipc_lock= /usr/sbin/vault && \
  vault --version && \
  sed -i '/root/s/ash/bash/g' /etc/passwd
RUN wget -O- -nv https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b /bin -d ${GOLANGCI_LINT_VERSION}
# Base Go tools needed for VS code Go extension
RUN go install golang.org/x/tools/gopls@${GOPLS_VERSION}
RUN go install github.com/ramya-rao-a/go-outline@latest 
RUN go install golang.org/x/tools/cmd/guru@latest 
RUN go install golang.org/x/tools/cmd/gorename@latest 
RUN go install github.com/go-delve/delve/cmd/dlv@${DELVE_VERSION}
# Extra tools integrating with VS code
RUN go install github.com/fatih/gomodifytags@${GOMODIFYTAGS_VERSION}
RUN go install github.com/haya14busa/goplay/cmd/goplay@${GOPLAY_VERSION} 
RUN go install github.com/cweill/gotests/...@${GOTESTS_VERSION} 
RUN go install github.com/davidrjenni/reftools/cmd/fillstruct@latest
# Extra Tools
RUN GO111MODULE=on  go install mvdan.cc/gofumpt@latest
RUN GO111MODULE=on  go install github.com/uudashr/gopkgs/v2/cmd/gopkgs@latest
RUN GO111MODULE=on  go install github.com/cuonglm/gocmt@latest
RUN rm -rf $GOPATH/pkg/* $GOPATH/src/* /root/.cache/go-build
RUN go env -w GOPRIVATE=github.com/crizstian
# Install Terraform
RUN git clone --depth=1 https://github.com/tfutils/tfenv.git ~/.tfenv && \ 
  echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> /bin/envs && \
  ln -s ~/.tfenv/bin/* /usr/local/bin
RUN which tfenv && \
  tfenv install latest && \
  tfenv use latest

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/linux/amd64/kubectl && \
  chmod +x ./kubectl && \
  sudo mv ./kubectl /usr/local/bin/kubectl && \
  kubectl version --client

WORKDIR /workspace
