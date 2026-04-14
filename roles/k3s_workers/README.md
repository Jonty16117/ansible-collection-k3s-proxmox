# k3s_workers

Joins worker nodes to k3s cluster.

## Description

This role:
- Joins worker nodes to an existing k3s cluster
- Applies worker role labels (k3s auto-adds `node-role.kubernetes.io/worker=true`)
- Configures kubelet parameters
- Supports custom labels

## Requirements

- Alpine Linux with k3s prerequisites applied
- Control plane must be installed and running
- SSH access to control plane for labeling

## Role Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `k3s_workers_version` | `"{{ k3s_version }}"` | k3s version to install |
| `k3s_workers_token` | `"{{ k3s_token }}"` | Cluster token |
| `k3s_workers_labels` | `[]` | Additional labels (k3s auto-adds `node-role.kubernetes.io/worker=true`) |
| `k3s_workers_extra_labels` | `[]` | Additional custom labels |

## Label Format

```yaml
k3s_workers_extra_labels:
  - "topology.kubernetes.io/zone=zone1"
  - "custom-label=value"
```

## Dependencies

- `community.k3s_proxmox.k3s_control_plane` role (must run first)

## Example Playbook

```yaml
- name: Join worker nodes
  hosts: workers
  become: true
  
  roles:
    - role: community.k3s_proxmox.k3s_workers
```

## Testing

```bash
cd roles/k3s_workers
molecule test
```

## License

GPL v3

## Author Information

FlashTrack Team and community contributors