#!/bin/bash
# Setup Ansible Vault password file

VAULT_FILE="ansible/.vault_pass"

if [ -f "$VAULT_FILE" ]; then
    exit 0
fi

read -s -p "Vault password: " pass
echo ""
read -s -p "Confirm: " pass_confirm
echo ""

if [ "$pass" != "$pass_confirm" ]; then
    echo "Passwords do not match."
    exit 1
fi

echo "$pass" > "$VAULT_FILE"
chmod 600 "$VAULT_FILE"

if ! grep -q ".vault_pass" .gitignore 2>/dev/null; then
    echo "**/.vault_pass" >> .gitignore
fi
