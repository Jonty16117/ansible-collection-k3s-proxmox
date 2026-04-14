# Variable Mapping: User vars.yml to Collection

This document shows how variables defined in `group_vars/all/vars.yml` are used by the collection.

## ✅ Verified Variable Connections

### k3s_cluster_topology
| User Variable | Collection Usage | Status |
|--------------|------------------|--------|
| `control_plane.count` | Used in `calculate-nodes.yml` to create N CP nodes | ✅ |
| `control_plane.memory` | Passed to VMs via `k3s_node_memory` hostvar | ✅ |
| `control_plane.disk` | Passed to VMs via `k3s_node_disk` hostvar | ✅ |
| `control_plane.cpu_cores` | Passed to VMs via `k3s_node_cpu_cores` hostvar | ✅ |
| `control_plane.vmid_start` | Used to calculate VMID (start + index) | ✅ |
| `control_plane.ip_start` | Used to calculate IP (prefix + start + index) | ✅ |
| `control_plane.naming` | Template for node names (e.g., `k8-cp-{id}`) | ✅ |
| `workers.count` | Used in `calculate-nodes.yml` to create N workers | ✅ |
| `workers.memory` | Passed to VMs via `k3s_node_memory` hostvar | ✅ |
| `workers.disk` | Passed to VMs via `k3s_node_disk` hostvar | ✅ |
| `workers.cpu_cores` | Passed to VMs via `k3s_node_cpu_cores` hostvar | ✅ |
| `workers.vmid_start` | Used to calculate VMID (start + index) | ✅ |
| `workers.ip_start` | Used to calculate IP (prefix + start + index) | ✅ |
| `workers.naming` | Template for node names (e.g., `k8-wk-{id}`) | ✅ |
| `skip_warnings` | Used in `warnings.yml` to suppress output | ✅ |

### k3s_network
| User Variable | Collection Usage | Status |
|--------------|------------------|--------|
| `base_cidr` | Parsed to extract network prefix for IP calculation | ✅ |
| `gateway` | Used in VM network config (ipconfig0 gateway) | ✅ |
| `bridge` | Used in VM network config (net0 bridge) | ✅ |
| `dns_servers` | Used in cloud-init DNS configuration | ✅ |

### SSH Configuration
| User Variable | Collection Usage | Status |
|--------------|------------------|--------|
| `k3s_ssh_key_path` | Used in `add-hosts.yml` and `proxmox_vm` role | ✅ |

### K3S Configuration
| User Variable | Collection Usage | Status |
|--------------|------------------|--------|
| `k3s_version` | Passed to all nodes; used in install scripts | ✅ |
| `k3s_token` | Passed to all nodes; used for cluster join | ✅ |

### Cilium Configuration
| User Variable | Collection Usage | Status |
|--------------|------------------|--------|
| `enabled` | `k3s_cilium_enabled` - controls Cilium installation | ✅ |
| `version` | `k3s_cilium_version` - Cilium version to install | ✅ |
| `lb_pool_start` | `k3s_cilium_lb_pool_start` - LB IP pool start | ✅ |
| `lb_pool_end` | `k3s_cilium_lb_pool_end` - LB IP pool end | ✅ |
| `optimized` | `k3s_cilium_optimized` - resource optimization | ✅ |
| `hubble_enabled` | `k3s_cilium_hubble_enabled` - Hubble observability | ✅ |
| `direct_routing` | `k3s_cilium_direct_routing` - native routing mode | ✅ |

### Proxmox Configuration
| User Variable | Collection Usage | Status |
|--------------|------------------|--------|
| `k3s_proxmox_template_vmid` | Source VM template for cloning | ✅ |
| `k3s_proxmox_node` | Target Proxmox node name | ✅ |

## Data Flow

```
vars.yml
    ↓
cluster_config role
    ↓ (calculates)
_k3s_cp_nodes, _k3s_worker_nodes
    ↓ (add_host module)
Ansible inventory (control_plane, workers groups)
    ↓ (hostvars)
proxmox_vm role creates VMs with:
  - memory: hostvars.k3s_node_memory
  - disk: hostvars.k3s_node_disk
  - cpu_cores: hostvars.k3s_node_cpu_cores
  - vmid: hostvars.k3s_node_vmid
    ↓
k3s_prerequisites role prepares nodes
    ↓
k3s_control_plane role installs k3s + Cilium
    ↓
k3s_workers role joins workers
```

## How Variables Propagate

### 1. Topology → Node Calculation
```yaml
# In calculate-nodes.yml
_node_memory: "{{ _override.memory | default(k3s_cluster_topology.control_plane.memory) }}"
_node_disk: "{{ _override.disk | default(k3s_cluster_topology.control_plane.disk) }}"
_node_cpu: "{{ _override.cpu_cores | default(k3s_cluster_topology.control_plane.cpu_cores) }}"
```

### 2. Node Data → Host Variables
```yaml
# In add-hosts.yml
k3s_node_vmid: "{{ item.vmid }}"
k3s_node_memory: "{{ item.memory }}"
k3s_node_disk: "{{ item.disk }}"
k3s_node_cpu_cores: "{{ item.cpu_cores }}"
```

### 3. Host Variables → VM Creation
```yaml
# In proxmox_vm/tasks/create.yml
memory: "{{ item.memory }}"        # From hostvars via build-vm-list
disk: "{{ item.disk }}"            # Used in qm resize command
cores: "{{ item.cpu_cores }}"
```

## Per-Node Overrides (Advanced)

The collection supports overriding specific nodes using `k3s_node_overrides`:

```yaml
# In your vars.yml
k3s_node_overrides:
  k8-cp-1:
    memory: 6144
    disk: "10G"
    cpu_cores: 4
```

This is checked in `calculate-nodes.yml`:
```yaml
_override: "{{ k3s_node_overrides[_node_name] | default({}) }}"
_node_memory: "{{ _override.memory | default(k3s_cluster_topology.control_plane.memory) }}"
```

## Summary

**All variables in your `vars.yml` are properly respected!** The collection uses them through:
1. Direct reference in `cluster_config` role defaults
2. Host variable injection via `add_host` module
3. Template lookups in VM creation tasks
4. Default value fallbacks with `| default()` filters
