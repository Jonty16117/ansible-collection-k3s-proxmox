# k3s_prerequisites

Prepares Alpine Linux nodes for k3s installation with Cilium CNI.

## Description

This role prepares nodes by:
- Installing required packages (curl, qemu-guest-agent)
- Setting sysctl parameters for Kubernetes networking
- Configuring BPF filesystem mounts for Cilium
- Enabling required services (qemu-guest-agent)
- Disabling unnecessary services (crond, syslog)

## Requirements

- Alpine Linux (tested on 3.18+)
- Root or sudo access

## Role Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `k3s_prereq_packages` | `[curl, qemu-guest-agent]` | Packages to install |
| `k3s_prereq_packages_remove` | `[]` | Packages to remove |
| `k3s_prereq_services_disable` | `[crond, syslog]` | Services to disable |
| `k3s_prereq_services_enable` | `[qemu-guest-agent]` | Services to enable |
| `k3s_prereq_sysctl` | (see defaults) | Sysctl parameters |
| `k3s_prereq_bpf_mount` | /sys/fs/bpf | BPF mount point |

## Dependencies

None

## Example Playbook

```yaml
- name: Prepare k3s nodes
  hosts: k3s_cluster
  become: true
  
  roles:
    - role: jonty16117.k3s_proxmox.k3s_prerequisites
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