# Justfile for jonty16117.k3s_proxmox Ansible Collection
# https://github.com/casey/just
#
# This project uses a virtual environment (.venv) for dependencies.
# Run `just setup` to create venv and install deps.

# Virtual environment paths
venv_path := ".venv"
python := venv_path + "/bin/python"
pip := venv_path + "/bin/pip"

# Default recipe - show help
default:
    @just --list

# Setup: Create venv and install dependencies
setup:
    @echo "Creating virtual environment..."
    python3 -m venv {{venv_path}}
    {{pip}} install --upgrade pip
    {{pip}} install -r requirements.txt
    @echo "✅ Setup complete! Activate with: source {{venv_path}}/bin/activate"

# Run Molecule tests for roles that support it (currently only k3s_prerequisites)
test:
    @echo "Testing k3s_prerequisites role..."
    cd roles/k3s_prerequisites && ../../{{venv_path}}/bin/molecule test

# Run tests for a specific role (usage: just test-role proxmox_vm)
test-role role:
    cd roles/{{role}} && ../../{{venv_path}}/bin/molecule test

# Run syntax check on all playbooks using venv ansible
syntax-check:
    {{venv_path}}/bin/ansible-playbook playbooks/deploy.yml --syntax-check
    {{venv_path}}/bin/ansible-playbook playbooks/destroy.yml --syntax-check
    {{venv_path}}/bin/ansible-playbook playbooks/health-check.yml --syntax-check

# Lint all YAML files (relaxed settings, continues on errors)
lint:
    {{venv_path}}/bin/yamllint -d relaxed playbooks/ roles/ || true
    {{venv_path}}/bin/ansible-lint playbooks/ || true

# Build collection tarball using venv ansible-galaxy
build:
    {{venv_path}}/bin/ansible-galaxy collection build --force

# Install collection locally (builds first)
install: build
    {{venv_path}}/bin/ansible-galaxy collection install jonty16117-k3s_proxmox-*.tar.gz --force

# Clean build artifacts and venv
clean:
    rm -f jonty16117-k3s_proxmox-*.tar.gz
    rm -rf .cache
    rm -rf {{venv_path}}

# Deploy cluster (usage: just deploy)
deploy:
    {{venv_path}}/bin/ansible-playbook -i my-inventory/ playbooks/deploy.yml

# Destroy cluster
destroy:
    {{venv_path}}/bin/ansible-playbook -i my-inventory/ playbooks/destroy.yml

# Health check
health:
    {{venv_path}}/bin/ansible-playbook -i my-inventory/ playbooks/health-check.yml

# Show collection info
info:
    {{venv_path}}/bin/ansible-galaxy collection list jonty16117.k3s_proxmox || echo "Collection not installed"

# Show venv info
venv-info:
    @echo "Virtual environment: {{venv_path}}"
    @echo "Python: {{python}}"
    {{python}} --version
    @echo ""
    @echo "Installed tools:"
    {{venv_path}}/bin/ansible --version | head -1
    {{venv_path}}/bin/molecule --version | head -1
    {{venv_path}}/bin/yamllint --version
    {{venv_path}}/bin/ansible-lint --version | head -1

# Run all static checks without requiring VMs (fast feedback)
test-all: lint syntax-check validate-roles
    @echo "✅ All static tests passed!"

# Validate role structure and defaults
validate-roles:
    @echo "Checking role structure..."
    @for role in roles/*/; do \
        if [ ! -f "$role/defaults/main.yml" ]; then \
            echo "❌ Missing defaults/main.yml in $role"; \
            exit 1; \
        fi; \
        if [ ! -f "$role/tasks/main.yml" ]; then \
            echo "❌ Missing tasks/main.yml in $role"; \
            exit 1; \
        fi; \
        echo "✅ $role OK"; \
    done

# Check all playbooks can be parsed
validate-playbooks:
    @echo "Validating playbooks..."
    @for playbook in playbooks/*.yml; do \
        echo "Checking $playbook..."; \
        {{venv_path}}/bin/ansible-playbook "$playbook" --syntax-check || exit 1; \
    done

# Quick sanity check using molecule (requires docker)
# NOTE: User must be in the 'docker' group to run without sudo.
# To fix: sudo usermod -aG docker $USER && newgrp docker
#
# HARMLESS WARNINGS (can be ignored):
# - "Driver docker does not provide a schema" - molecule-plugins limitation
# - "Another version of 'collection' was found" - multiple collection paths exist
test-molecule: setup
    @echo "Running molecule tests (requires Docker)..."
    @echo ""
    cd roles/k3s_prerequisites && ../../{{venv_path}}/bin/molecule test
