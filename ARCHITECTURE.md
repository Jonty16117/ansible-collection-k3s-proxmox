# Architecture

## Collection Structure

```
community.k3s_proxmox/
├── galaxy.yml              # Collection metadata
├── meta/runtime.yml        # Ansible requirements
├── README.md              # Main documentation
├── QUICKSTART.md          # Quick start guide
├── justfile               # Build & automation commands
│
├── playbooks/
│   ├── deploy.yml         # Main deployment
│   ├── destroy.yml        # Teardown
│   └── health-check.yml   # Verification
│
├── roles/
│   ├── cluster_config/     # Phase 0: Bootstrap
│   ├── proxmox_vm/         # Phase 1: Infrastructure
│   ├── k3s_prerequisites/  # Phase 2: Node prep
│   ├── k3s_control_plane/  # Phase 3: k3s install
│   └── k3s_workers/        # Phase 4: Workers
│
└── docs/
    └── examples/          # Example configurations
```

## Role Dependencies

```
deploy.yml
│
├── Phase 0: cluster_config (localhost)
│   └── Outputs: groups[control_plane], groups[workers]
│
├── Phase 1: proxmox_vm (proxmox_nodes)
│   └── Creates VMs in Proxmox
│
├── Phase 2: k3s_prerequisites (k3s_cluster)
│   └── Prepares Alpine Linux nodes
│
├── Phase 3: k3s_control_plane (control_plane)
│   └── Installs k3s server + Cilium
│
└── Phase 4: k3s_workers (workers)
    └── Joins agents to cluster
```

## Variable Precedence

```
1. host_vars/<node>.yml              # Per-node overrides
2. group_vars/all/k3s.yml            # Environment config
3. group_vars/all/vault.yml          # Secrets
4. role defaults                     # Collection defaults
```

## Key Design Decisions

1. **Dynamic Inventory**: No static inventory files to maintain
2. **Node Type Overrides**: Via group_vars for CP or worker node types
3. **Idempotent**: All roles support rerun safely
4. **Tested**: Molecule tests for every role