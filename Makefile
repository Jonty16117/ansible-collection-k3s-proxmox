.PHONY: test build install clean

# Run all Molecule tests
test:
	@echo "Testing cluster_config role..."
	cd roles/cluster_config && molecule test
	@echo "Testing proxmox_vm role..."
	cd roles/proxmox_vm && molecule test
	@echo "Testing k3s_prerequisites role..."
	cd roles/k3s_prerequisites && molecule test
	@echo "Testing k3s_control_plane role..."
	cd roles/k3s_control_plane && molecule test
	@echo "Testing k3s_workers role..."
	cd roles/k3s_workers && molecule test

# Build collection
build:
	ansible-galaxy collection build --force

# Install collection locally
install: build
	ansible-galaxy collection install community-k3s_proxmox-*.tar.gz --force

# Clean build artifacts
clean:
	rm -f community-k3s_proxmox-*.tar.gz
	rm -rf .cache

# Deploy to development
deploy-dev:
	ansible-playbook -i inventory/dev/ playbooks/deploy.yml

# Destroy development
destroy-dev:
	ansible-galaxy collection install community-k3s_proxmox-*.tar.gz --force

# Clean build artifacts
clean:
	rm -f community-k3s_proxmox-*.tar.gz
	rm -rf .cache

# Deploy to development
deploy-dev:
	ansible-playbook -i inventory/dev/ playbooks/deploy.yml

# Destroy development
destroy-dev:
	ansible-playbook -i inventory/dev/ playbooks/destroy.yml