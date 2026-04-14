# Quick Start Guide

Deploy a k3s cluster on Proxmox in 5 minutes.

## Installation

```bash
# From Git
git clone https://github.com/Jonty16117/ansible-collection-k3s-proxmox.git
cd jonty16117.k3s_proxmox

# Or copy to your project
cp -r jonty16117.k3s_proxmox /path/to/your/project/
```

## 1. Create Inventory

```bash
mkdir -p my-inventory/group_vars/all
```

### `my-inventory/hosts.yml`
```yaml
all:
  children:
    proxmox_nodes:
      hosts:
        pm02:
          ansible_host: pm02
          ansible_user: root
```

### `my-inventory/group_vars/all/k3s.yml`
```yaml
k3s_cluster_topology:
  control_plane:
    count: 3
    memory: 4096
  workers:
    count: 2
    memory: 2048

k3s_network:
  base_cidr: "192.168.178.0/24"
  gateway: "192.168.178.1"
  dns_servers:
    - "192.168.178.1"
    - "1.1.1.1"

k3s_ssh_key_path: "{{ playbook_dir }}/.ssh/k8s_id_ed25519"
```

### `my-inventory/group_vars/all/vault.yml`
```bash
ansible-vault encrypt my-inventory/group_vars/all/vault.yml
```

Content:
```yaml
vault_proxmox_api_host: pm02
vault_proxmox_api_user: root@pam
vault_proxmox_api_token_id: ansible
vault_proxmox_api_token_secret: "your-token-here"
```

## 2. Deploy

```bash
ansible-playbook -i my-inventory/ playbooks/deploy.yml
```

## 3. Verify

```bash
# From first control plane node
ssh -i .ssh/k8s_id_ed25519 root@192.168.178.210
kubectl get nodes
kubectl -n kube-system get pods
```

## Destroy

```bash
ansible-playbook -i my-inventory/ playbooks/destroy.yml
```

## Per-Node Overrides

Create `my-inventory/host_vars/k8-cp-1.yml`:
```yaml
k3s_node_memory: 6144
k3s_node_disk: "10G"
```

