FROM ubuntu:noble

ARG ANSIBLE_VERSION="11.1.0"
ARG GOVC_VERSION="v0.46.3"
ARG PACKER_VERSION="1.11.2"
ARG TERRAFORM_VERSION="1.10.3"
ARG KUBECTL_VERSION="v1.32.0"
ARG HELM_VERSION="v3.16.4"
ARG K3SUP_VERSION="0.13.6"

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONDONTWRITEBYTECODE=True
ENV PATH="$PATH:/root/.local/bin"
ENV TZ=UTC

# Install required packages
RUN apt-get update && \
    apt-get install -y bash \
    bash-completion \
    openssh-client \
    curl \
    dumb-init \
    git \
    jq \
    make \
    inetutils-ping \
    python3-hvac \
    pipx \
    unzip \
    vim \
    wget

# Install Ansible and hvac
RUN pipx ensurepath \
    && pipx install --include-deps ansible==${ANSIBLE_VERSION} \
    && pipx inject ansible hvac

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
    && unzip -o '*.zip' -d /usr/local/bin \
    && rm *.zip \
    && chmod +x /usr/local/bin/*

# Install k3sup
RUN curl -sSL https://github.com/alexellis/k3sup/releases/download/${K3SUP_VERSION}/k3sup > k3sup \
    && chmod +x k3sup \
    && mv k3sup /usr/bin/k3sup

# Clean up
RUN apt-get clean autoclean; \
    apt-get autoremove --yes; \
    rm -rf /var/lib/{apt,dpkg,cache,log}/

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/bin/bash"]
