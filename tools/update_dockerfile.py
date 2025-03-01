import re
import requests

urls = {
    "ANSIBLE_VERSION": "https://pypi.org/pypi/ansible/json",
    "GOVC_VERSION": "https://api.github.com/repos/vmware/govmomi/releases/latest",
    "PACKER_VERSION": "https://api.github.com/repos/hashicorp/packer/releases/latest",
    "TERRAFORM_VERSION": "https://api.github.com/repos/hashicorp/terraform/releases/latest",
    "OPENTOFU_VERSION": "https://api.github.com/repos/alexellis/opentofu/releases/latest",
    "KUBECTL_VERSION": "https://api.github.com/repos/kubernetes/kubernetes/releases/latest",
    "HELM_VERSION": "https://api.github.com/repos/helm/helm/releases/latest",
    "K3SUP_VERSION": "https://api.github.com/repos/alexellis/k3sup/releases/latest"
}


def get_latest_version(url, version_key):
    response = requests.get(url, timeout=30)
    data = response.json()
    if version_key == "ANSIBLE_VERSION":
        return data["info"]["version"]
    return data["tag_name"]


latest_versions = {key: get_latest_version(url, key) for key, url in urls.items()}

with open("Dockerfile", "r", encoding="utf8") as file:
    dockerfile_content = file.read()

updated = False
for key, version in latest_versions.items():
    if key in ["PACKER_VERSION", "TERRAFORM_VERSION"]:
        version = version.lstrip('v')
    new_content = re.sub(f'{key}="[^"]+"', f'{key}="{version}"', dockerfile_content)
    if new_content != dockerfile_content:
        updated = True
        dockerfile_content = new_content

if updated:
    with open("Dockerfile", "w", encoding="utf8") as file:
        file.write(dockerfile_content)
    print("Dockerfile updated with the latest versions.")
else:
    print("Dockerfile is already up to date.")
