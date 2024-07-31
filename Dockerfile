FROM ubuntu:jammy

ARG ANSIBLE_VERSION="10.2.0"
ARG GOVC_VERSION="v0.39.0"
ARG PACKER_VERSION="1.11.1"
ARG TERRAFORM_VERSION="1.9.3"
ARG KUBECTL_VERSION="v1.30.3"
ARG HELM_VERSION="v3.15.3"

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONDONTWRITEBYTECODE=True
ENV TZ=UTC

# Install required packages
RUN apt-get update && \
    apt-get install -y bash \
    bash-completion \
    curl \
    dumb-init \
    git \
    inetutils-ping \
    python3-pip \
    unzip \
    vim \
    wget

# Install Ansible and hvac Python packages
RUN pip3 install ansible==${ANSIBLE_VERSION} \
    && pip3 install hvac

# Install Helm
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
    | bash -s -- -v ${HELM_VERSION}

# Install kubectl
RUN curl -L https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
    -o /usr/local/bin/kubectl

# Install govc
RUN curl -L -o - https://github.com/vmware/govmomi/releases/download/${GOVC_VERSION}/govc_$(uname -s)_$(uname -m).tar.gz \
    | tar -C /usr/local/bin -xvzf - govc

# Install Terraform and Packer
RUN curl -LO https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && curl -LO https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip \
    && unzip '*.zip' -d /usr/local/bin \
    && rm *.zip \
    && chmod +x /usr/local/bin/*

# Clean up
RUN apt-get clean autoclean; \
    apt-get autoremove --yes; \
    rm -rf /var/lib/{apt,dpkg,cache,log}/

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/bin/bash"]
