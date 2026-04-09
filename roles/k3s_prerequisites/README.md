# k3s_prerequisites

Prepares Alpine Linux nodes for k3s installation with Cilium CNI.

## Description

This role prepares nodes by:
- Installing required packages (curl, qemu-guest-agent, zram-init)
- Removing unnecessary packages
- Configuring kernel modules (bpf, br_netfilter, overlay)
- Setting sysctl parameters for Kubernetes networking
- Configuring zRAM for compressed swap
- Setting up BPF filesystem mounts for Cilium
- Optimizing services

## Requirements

- Alpine Linux (tested on 3.18+)
- Root or sudo access

## Role Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `k3s_prereq_packages` | `[curl, qemu-guest-agent, zram-init]` | Packages to install |
| `k3s_prereq_packages_remove` | `[busybox-extras]` | Packages to remove |
| `k3s_prereq_services_disable` | `[crond, syslog]` | Services to disable |
| `k3s_prereq_services_enable` | `[qemu-guest-agent]` | Services to enable |
| `k3s_prereq_modules` | `[bpf, br_netfilter, overlay, vxlan]` | Kernel modules |
| `k3s_prereq_sysctl` | (see defaults) | Sysctl parameters |
| `k3s_prereq_zram_enabled` | true | Enable zRAM swap |
| `k3s_prereq_zram_size` | "50%" | zRAM size (% of RAM) |
| `k3s_prereq_bpf_mount` | /sys/fs/bpf | BPF mount point |

## Dependencies

None

## Example Playbook

```yaml
- name: Prepare k3s nodes
  hosts: k3s_cluster
  become: true
  
  roles:
    - role: community.k3s_proxmox.k3s_prerequisites
```

## Testing

```bash
cd roles/k3s_prerequisites
molecule test
```

## License

GPL v3

## Author Information

FlashTrack Team and community contributors