+# DockerStacked

Deploy a GLPI instance on Docker Swarm using LXD containers, Terraform and Ansible.

## Disclaimer

I made an iptables change in the script, be careful with it.
You can see what's done in the Makefile (lines 19-21) and delete those after.
But it wasn't working without them so I added them to the script so it always works ^^.
If you already have docker rules feel free to comment lines 19-21.

## Prerequisites

Ubuntu 20.04+ with sudo access. Install dependencies:

```bash
make install
```

Then initialize LXD if needed (`lxd init`, defaults are fine) and re-login for Docker group.

## Usage

```bash
make vault    # set database and admin passwords
make deploy   # provision infra + deploy stack
make status   # check cluster health
make logs     # tail GLPI logs
make destroy  # tear everything down
```

## Structure

```
├── main.tf                 # LXD container definitions
├── Makefile                # task runner
├── install.sh              # dependency installer
├── setup-vault.sh          # vault password setup
└── ansible/
    ├── site.yml            # main playbook
    ├── ansible.cfg
    ├── inventory/
    │   └── hosts.yml
    ├── group_vars/
    │   └── all.yml         # shared variables
    └── roles/
        ├── common/         # container bootstrap
        ├── docker/         # docker + swarm setup
        └── glpi/           # app deployment + config
```

## Vault

Secrets are stored in `ansible/roles/glpi/vars/vault.yml` (encrypted with `ansible-vault`).

If the file is missing, `make vault` or `make deploy` will create it from the template. Edit with:

```bash
make vault
```

Required variables: `vault_glpi_db_root_password`, `vault_glpi_db_password`, `vault_glpi_admin_password`, `vault_glpi_default_users_password`.
