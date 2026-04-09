# proxmox_vm

Manages VM lifecycle in Proxmox VE for k3s clusters.

## Description

This role handles:
- Cloning VMs from Alpine Linux templates
- Configuring VM hardware (memory, CPU, disk)
- Setting up cloud-init (SSH keys, networking, DNS)
- Waiting for VMs to be SSH-accessible
- Configuring DNS on Alpine Linux
- Destroying VMs (idempotent)

## Requirements

- Proxmox VE >= 7.0
- Alpine Linux cloud-init template (VMID 9600 recommended)
- Proxmox API token with VM management permissions
- SSH key pair for node access

## Role Variables

### Required

| Variable | Description |
|----------|-------------|
| `vault_proxmox_api_token_secret` | Proxmox API token secret (must be in vault) |

### Optional

| Variable | Default | Description |
|----------|---------|-------------|
| `proxmox_vm_state` | `present` | `present` to create, `absent` to destroy |
| `k3s_proxmox_template_vmid` | 9600 | Source template VMID |
| `k3s_proxmox_node` | "pm02" | Proxmox node name |
| `k3s_proxmox_cloudinit_user` | "root" | Default cloud-init user |
| `k3s_proxmox_cloudinit_ssh_key_path` | `"{{ playbook_dir }}/.ssh/id_ed25519"` | SSH private key path |
| `proxmox_vm_clone_timeout` | 300 | Timeout for VM clone (seconds) |
| `proxmox_ssh_timeout` | 300 | Timeout for SSH availability (seconds) |
| `proxmox_vm_dry_run` | false | Set to true for testing without Proxmox |

## Dependencies

- `community.k3s_proxmox.cluster_config` role (must run first to populate inventory)

## Example Playbook

```yaml
- name: Create VMs
  hosts: proxmox_nodes
  gather_facts: false
  
  roles:
    - role: community.k3s_proxmox.proxmox_vm
      vars:
        proxmox_vm_state: present
```

## Testing

```bash
cd roles/proxmox_vm
molecule test
```

## License

GPL v3

## Author Information

FlashTrack Team and community contributors