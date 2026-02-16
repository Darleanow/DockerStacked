# DockerStacked

.PHONY: help deploy destroy status logs vault test install setup-vault

ANSIBLE_DIR = ansible

help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "  deploy     Provision and deploy full stack"
	@echo "  destroy    Tear down all infrastructure"
	@echo "  status     Show cluster status"
	@echo "  logs       Tail GLPI container logs"
	@echo "  vault      Edit encrypted secrets"
	@echo "  test       Syntax-check Ansible playbooks"
	@echo "  install    Install prerequisites"

deploy: setup-vault
	@echo "[1/3] Applying network fix..."
	@sudo iptables -I DOCKER-USER -i lxdbr0 -j ACCEPT 2>/dev/null || true
	@sudo iptables -I DOCKER-USER -o lxdbr0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || true
	@echo "[2/3] Provisioning infrastructure..."
	terraform init -input=false
	terraform apply -auto-approve
	@echo "Waiting for LXD containers..."
	@until lxc list -f csv -c s 2>/dev/null | grep -c RUNNING | grep -q 3; do sleep 2; done
	@echo "[3/3] Deploying stack..."
	cd $(ANSIBLE_DIR) && ansible-playbook site.yml

setup-vault:
	@./setup-vault.sh
	@if [ ! -f $(ANSIBLE_DIR)/roles/glpi/vars/vault.yml ]; then \
		echo "Creating vault from template..."; \
		cp $(ANSIBLE_DIR)/roles/glpi/vars/vault.example.yml $(ANSIBLE_DIR)/roles/glpi/vars/vault.yml; \
		cd $(ANSIBLE_DIR) && ansible-vault encrypt roles/glpi/vars/vault.yml; \
		echo "Done. Edit with 'make vault'"; \
	fi

destroy:
	terraform destroy -auto-approve

status:
	@lxc list
	@echo ""
	@lxc exec swarm-manager -- docker node ls 2>/dev/null || echo "Swarm not initialized"
	@echo ""
	@lxc exec swarm-manager -- docker service ls 2>/dev/null || echo "No services"
	@echo ""
	@lxc exec swarm-manager -- docker ps 2>/dev/null || echo "No containers"

logs:
	@lxc exec swarm-manager -- docker logs glpi-app 2>/dev/null || echo "Container not found"

vault: setup-vault
	@if [ ! -f $(ANSIBLE_DIR)/roles/glpi/vars/vault.yml ]; then \
		echo "Creating vault from template..."; \
		cp $(ANSIBLE_DIR)/roles/glpi/vars/vault.example.yml $(ANSIBLE_DIR)/roles/glpi/vars/vault.yml; \
		cd $(ANSIBLE_DIR) && ansible-vault encrypt roles/glpi/vars/vault.yml; \
	fi
	cd $(ANSIBLE_DIR) && ansible-vault edit roles/glpi/vars/vault.yml

test:
	cd $(ANSIBLE_DIR) && ansible-playbook site.yml --syntax-check

install:
	sudo ./install.sh
