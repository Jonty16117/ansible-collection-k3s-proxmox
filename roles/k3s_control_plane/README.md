# k3s_control_plane

Installs k3s control plane with Cilium CNI.

## Description

This role installs and configures:
- First k3s control plane node (single or HA setup)
- Additional HA control plane nodes
- Cilium CNI with eBPF networking
- L2 LoadBalancer for host-based ingress routing
- Optional Hubble observability

## Requirements

- Alpine Linux with k3s prerequisites applied
- First control plane node must have `k3s_is_first_node: true`
- Proxmox VMs created and SSH-accessible

## Role Variables

### Required

| Variable | Description |
|----------|-------------|
| `k3s_token` | Cluster token for node authentication |

### Optional

| Variable | Default | Description |
|----------|---------|-------------|
| `k3s_version` | `"v1.30.6+k3s1"` | k3s version to install |
| `k3s_cluster_name` | `""` | Rename cluster context in kubeconfig |
| `k3s_cilium_enabled` | `true` | Install Cilium CNI |
| `k3s_cilium_version` | `"1.19.2"` | Cilium version |
| `k3s_cilium_l2_enabled` | `false` | Enable L2 LoadBalancer |
| `k3s_cilium_lb_pool_cidr` | `"192.168.178.240/32"` | LB IP pool CIDR (single IP) |
| `k3s_cluster_cidr` | `"10.42.0.0/16"` | Pod network CIDR |
| `k3s_service_cidr` | `"10.43.0.0/16"` | Service network CIDR |
| `k3s_cilium_hubble_enabled` | `false` | Enable Hubble observability |
| `k3s_cilium_optimized` | `true` | Enable resource optimization |

## Dependencies

- `jonty16117.k3s_proxmox.k3s_prerequisites` role (must run first)

## Example Playbook

```yaml
- name: Install k3s control plane
  hosts: control_plane
  become: true
  
  roles:
    - role: jonty16117.k3s_proxmox.k3s_control_plane
```

## Testing

```bash
cd roles/k3s_control_plane
molecule test
```

## License

GPL v3

## Author Information

FlashTrack Team and community contributors
