# cluster_config

Calculates cluster topology and dynamically generates Ansible inventory for k3s clusters on Proxmox.

## Description

This role is the foundation of the community.k3s_proxmox collection. It:

1. Reads cluster topology configuration (number of control plane and worker nodes)
2. Validates the configuration (odd CP count, reasonable limits, etc.)
3. Calculates VM properties (names, IPs, VMIDs, resources)
4. Applies per-node overrides
5. Dynamically adds hosts to Ansible inventory using `add_host`

The role eliminates the need for manual inventory generation - cluster topology is defined in group_vars and calculated on-the-fly.

## Requirements

- Ansible >= 2.15.0
- `community.general` collection
- `ansible.utils` collection

## Role Variables

### User-Configurable Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `k3s_cluster_topology.control_plane.count` | 3 | Number of CP nodes (must be odd) |
| `k3s_cluster_topology.control_plane.memory` | 4096 | Memory in MB per CP node |
| `k3s_cluster_topology.control_plane.disk` | "4G" | Disk size |
| `k3s_cluster_topology.control_plane.cpu_cores` | 2 | vCPU cores per CP |
| `k3s_cluster_topology.control_plane.vmid_start` | 500 | Starting VMID |
| `k3s_cluster_topology.control_plane.ip_start` | 210 | Starting IP octet |
| `k3s_cluster_topology.control_plane.naming` | "k8-cp-{id}" | Naming pattern |
| `k3s_cluster_topology.workers.count` | 2 | Number of workers |
| `k3s_cluster_topology.workers.memory` | 2048 | Memory in MB per worker |
| `k3s_cluster_topology.workers.disk` | "4G" | Disk size |
| `k3s_cluster_topology.workers.cpu_cores` | 2 | vCPU cores per worker |
| `k3s_cluster_topology.workers.vmid_start` | 600 | Starting VMID |
| `k3s_cluster_topology.workers.ip_start` | 220 | Starting IP octet |
| `k3s_cluster_topology.workers.naming` | "k8-wk-{id}" | Naming pattern |
| `k3s_network.base_cidr` | "192.168.178.0/24" | Network CIDR |
| `k3s_network.gateway` | "192.168.178.1" | Default gateway |
| `k3s_network.dns_servers` | ["192.168.178.1", ...] | DNS servers |
| `k3s_node_overrides` | {} | Per-node customizations |
| `k3s_validate_topology` | true | Enable validation |

### Per-Node Override Format

```yaml
k3s_node_overrides:
  k8-cp-1:
    memory: 6144
    disk: "10G"
    cpu_cores: 4
  k8-wk-2:
    memory: 4096
```

### Generated Variables

After running this role, the following groups are populated:

- `control_plane` - Control plane node hostnames
- `workers` - Worker node hostnames
- `k3s_cluster` - All k3s nodes (control_plane + workers)

Each host has the following variables:

| Variable | Description |
|----------|-------------|
| `k3s_node_vmid` | VMID in Proxmox |
| `k3s_node_memory` | Memory in MB |
| `k3s_node_disk` | Disk size |
| `k3s_node_cpu_cores` | vCPU cores |
| `k3s_node_role` | "control-plane" or "worker" |
| `k3s_is_first_node` | true for first CP node |
| `ansible_host` | Node IP address |

## Dependencies

None

## Example Playbook

```yaml
---
- name: Configure cluster inventory
  hosts: localhost
  connection: local
  gather_facts: false
  
  roles:
    - role: community.k3s_proxmox.cluster_config

- name: Display inventory
  hosts: localhost
  connection: local
  gather_facts: false
  
  tasks:
    - name: Show control plane nodes
      ansible.builtin.debug:
        var: groups['control_plane']
        
    - name: Show worker nodes
      ansible.builtin.debug:
        var: groups['workers']
```

## Testing

Run Molecule tests:

```bash
cd roles/cluster_config
molecule test
```

## License

GPL v3

## Author Information

FlashTrack Team and community contributors