# k3s_control_plane

Installs k3s control plane with Cilium CNI.

## Description

This role installs and configures:
- First k3s control plane node (single or HA setup)
- Additional HA control plane nodes
- Cilium CNI with eBPF networking
- LoadBalancer IP pool configuration
- Hubble observability (optional)

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
| `k3s_control_plane_version` | `"{{ k3s_version }}"` | k3s version to install |
| `k3s_cilium_enabled` | true | Install Cilium CNI |
| `k3s_cilium_version` | "1.19.2" | Cilium version |
| `k3s_cilium_lb_pool_start` | "192.168.178.240" | LB IP pool start |
| `k3s_cilium_lb_pool_end` | "192.168.178.249" | LB IP pool end |
| `k3s_cilium_hubble_enabled` | true | Enable Hubble |
| `k3s_cilium_direct_routing` | true | Enable native routing (no encapsulation) |

## Dependencies

- `community.k3s_proxmox.k3s_prerequisites` role (must run first)

## Example Playbook

```yaml
- name: Install k3s control plane
  hosts: control_plane
  become: true
  
  roles:
    - role: community.k3s_proxmox.k3s_control_plane
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