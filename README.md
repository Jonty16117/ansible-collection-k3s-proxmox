# jonty16117.k3s_proxmox

[![Ansible Collection](https://img.shields.io/badge/collection-jonty16117.k3s_proxmox-blue)](https://galaxy.ansible.com/jonty16117/k3s_proxmox)
[![License](https://img.shields.io/badge/license-GPL%20v3-red)](LICENSE)

Lightweight [k3s](https://k3s.io/) cluster deployment on [Proxmox VE](https://www.proxmox.com/en/proxmox-virtual-environment) using Alpine Linux, Cilium CNI with eBPF networking, and L2 LoadBalancer announcement. Designed for local LAN environments.

## Features

- **Lightweight**: Production-ready k3s with minimal resource footprint
- **Alpine Linux**: Optimized OS for container workloads
- **Dynamic Inventory**: No manual inventory - cluster topology is calculated automatically
- **High Availability**: Automated HA control plane setup with embedded etcd
- **Cilium CNI**: Automatic installation with eBPF networking and observability
- **L2 LoadBalancer**: Cilium L2 announcement enabled by default
- **Idempotent**: Safe to rerun multiple times

## Requirements

- Ansible >= 2.15.0
- Proxmox VE >= 7.0
- Alpine Linux cloud-init template (with BIOS/UEFI boot, not EFI-only)
- SSH key pair for node access
- All cluster nodes must be on the same local LAN (same subnet)

## Installation

### From Ansible Galaxy

```bash
ansible-galaxy collection install jonty16117.k3s_proxmox
```

### From Git

```bash
git clone https://github.com/Jonty16117/ansible-collection-k3s-proxmox.git
cd jonty16117.k3s_proxmox
ansible-galaxy collection build
ansible-galaxy collection install jonty16117-k3s_proxmox-*.tar.gz
```

## Quick Start

### 1. Create Your Inventory

```bash
mkdir -p my-inventory/group_vars/all
```

### 2. Configure Proxmox Host (`my-inventory/hosts.yml`)

```yaml
---
all:
  children:
    proxmox_nodes:
      hosts:
        pm02:
          ansible_host: pm02
          ansible_user: root
```

### 3. Configure Cluster (`my-inventory/group_vars/all/k3s.yml`)

```yaml
---
# Cluster topology
k3s_cluster_topology:
  control_plane:
    count: 3                    # Must be odd (1, 3, 5...)
    memory: 4096                # MB RAM per CP node
    disk: "4G"                  # Disk size
    cpu_cores: 2                # vCPUs per node
  
  workers:
    count: 2                    # Can be 0 or more
    memory: 2048
    disk: "4G"
    cpu_cores: 2

# Network configuration
k3s_network:
  base_cidr: "192.168.178.0/24"
  gateway: "192.168.178.1"
  dns_servers:
    - "192.168.178.1"
    - "1.1.1.1"

# SSH key path
k3s_ssh_key_path: "{{ playbook_dir }}/../.ssh/k8s_id_ed25519"
```

### 4. Configure Secrets (`my-inventory/group_vars/all/vault.yml`)

Encrypt with: `ansible-vault encrypt my-inventory/group_vars/all/vault.yml`

```yaml
---
vault_proxmox_api_host: pm02
vault_proxmox_api_user: root@pam
vault_proxmox_api_token_id: ansible
vault_proxmox_api_token_secret: "your-secret-token-here"
```

### 5. Deploy

```bash
ansible-playbook -i my-inventory/ \
  ~/.ansible/collections/ansible_collections/community/k3s_proxmox/playbooks/deploy.yml
```

## Usage Examples

### Deploy Full Cluster

```bash
ansible-playbook -i my-inventory/ deploy.yml
```

### Deploy Only VMs

```bash
ansible-playbook -i my-inventory/ deploy.yml --tags proxmox
```

### Destroy Cluster

```bash
ansible-playbook -i my-inventory/ destroy.yml
```

### Health Check

```bash
ansible-playbook -i my-inventory/ health-check.yml
```

## Node Overrides

Override resources for control plane (CP) or worker (WK) nodes collectively:

```yaml
# my-inventory/group_vars/all/k3s.yml
k3s_cluster_topology:
  control_plane:
    count: 3
    memory: 6144              # Override CP memory
    disk: "10G"               # Override CP disk
    cpu_cores: 4              # Override CP CPUs
  
  workers:
    count: 2
    memory: 4096              # Override WK memory
    disk: "8G"                # Override WK disk
```

> **Note**: Per-node individual overrides are not yet supported. All CP nodes share the same resources, and all WK nodes share the same resources.

## Role Variables

### cluster_config

| Variable | Default | Description |
|----------|---------|-------------|
| `k3s_cluster_topology.control_plane.count` | 3 | Number of CP nodes (must be odd) |
| `k3s_cluster_topology.control_plane.memory` | 4096 | Memory in MB |
| `k3s_cluster_topology.workers.count` | 2 | Number of workers |
| `k3s_cluster_topology.workers.memory` | 2048 | Memory in MB |
| `k3s_network.base_cidr` | "192.168.178.0/24" | Network CIDR |
| `k3s_version` | "v1.30.6+k3s1" | k3s release |
| `k3s_cilium.enabled` | true | Install Cilium CNI |
| `k3s_cilium.version` | "1.19.2" | Cilium version |

### proxmox_vm

| Variable | Default | Description |
|----------|---------|-------------|
| `k3s_proxmox_template_vmid` | 9600 | Source VM template |
| `k3s_proxmox_node` | "pm02" | Proxmox node name |
| `proxmox_vm_state` | present | present/absent |

## Development

### Running Tests

```bash
# Test specific role
cd roles/cluster_config
molecule test

# Test all roles
make test
```

### Building Collection

```bash
ansible-galaxy collection build
ansible-galaxy collection install jonty16117-k3s_proxmox-*.tar.gz --force
```

## License

GPL v3 - See [LICENSE](LICENSE)

## Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Submit a pull request

## Support

- Issues: [GitHub Issues](https://github.com/Jonty16117/ansible-collection-k3s-proxmox/issues)
- Discussions: [GitHub Discussions](https://github.com/Jonty16117/ansible-collection-k3s-proxmox/discussions)

## Acknowledgments

- [k3s](https://k3s.io/) - Lightweight Kubernetes
- [Cilium](https://cilium.io/) - eBPF-based Networking
- [Proxmox VE](https://www.proxmox.com/) - Open-source virtualization