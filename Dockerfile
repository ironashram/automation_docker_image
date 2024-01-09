FROM ubuntu:jammy

ARG ANSIBLE_VERSION="9.1.0"
ARG GOVC_VERSION="v0.34.2"
ARG PACKER_VERSION="1.10.0"
ARG TERRAFORM_VERSION="1.6.6"
ARG K8S_VERSION="v1.28.5"
ARG HELM_VERSION="v3.13.3"

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONDONTWRITEBYTECODE=True
ENV TZ=UTC

RUN apt-get update && \
    apt-get install -y bash \
    bash-completion \
    curl \
    dumb-init \
    git \
    python3-pip \
    unzip \
    vim \
    wget \
    && pip3 install ansible==${ANSIBLE_VERSION} \
    && curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash -s -- -v ${HELM_VERSION} \
    && curl -L https://dl.k8s.io/release/${K8S_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl \
    && curl -L -o - https://github.com/vmware/govmomi/releases/download/${GOVC_VERSION}/govc_$(uname -s)_$(uname -m).tar.gz | tar -C /usr/local/bin -xvzf - govc \
    && curl -LO https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && curl -LO https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip \
    && unzip '*.zip' -d /usr/local/bin \
    && rm *.zip \
    && chmod +x /usr/local/bin/*

RUN apt-get clean autoclean; \
    apt-get autoremove --yes; \
    rm -rf /var/lib/{apt,dpkg,cache,log}/

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/bin/bash"]
