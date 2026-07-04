# Ephemeral Workstation

Terraform + Ansible to spin up a disposable Fedora 44 workstation on Hetzner Cloud, provision it, use it, and tear it down.

## What you get

- A Hetzner Cloud VM running Fedora 44.
- User `dusan` — **no password** (SSH-key login only), member of the `docker` group, passwordless `sudo`, `fish` as login shell.
- SSH hardened: key-only authentication (password auth disabled).
- Preinstalled: `git`, `fish`, `docker` (official Docker CE repo), `podman`, `tmux`, `htop`, `nodejs`/`npm`, and [Claude Code](https://claude.com/claude-code) (global npm install).
- Fish set up with [fisher](https://github.com/jorgebucaran/fisher) and plugins: `pure-fish/pure`, `dusansimic/fish-aliases`.
- Tools from GitHub releases into `/usr/local/bin`: [`eza`](https://github.com/eza-community/eza).
- `~/Projects` directory.
- Full system upgrade applied.

## Layout

```
terraform/   # provisions the VM, writes ansible/inventory/hosts.ini
ansible/     # roles: repositories, packages, update, user, directories
```

## Prerequisites

- Terraform >= 1.5
- Ansible + collections: `cd ansible && ansible-galaxy collection install -r requirements.yml`
- A Hetzner Cloud API token
- (Optional) `hcloud` CLI to check the image slug
- (Optional) [pre-commit](https://pre-commit.com) for the linting hooks

## Pre-commit hooks

`.pre-commit-config.yaml` runs on every commit:

- **terraform_fmt** + **terraform_validate** — format and validate the Terraform.
- **ansible-lint** — lint the roles and playbook (`production` profile, config in `ansible/.ansible-lint`).
- General hygiene: trailing whitespace, end-of-file, merge-conflict markers, private-key detection, YAML check.

Enable once:

```sh
pre-commit install
pre-commit run --all-files   # optional: run against everything now
```

## Usage

1. **Configure Terraform**

   ```sh
   cd terraform
   cp terraform.tfvars.example terraform.tfvars
   # edit terraform.tfvars: set hcloud_token, ssh_public_key, ssh_private_key_file
   ```

2. **Create the VM**

   ```sh
   terraform init
   terraform apply
   ```

   This boots the server and writes the Ansible inventory (`ansible/inventory/hosts.ini`, with the IP and private-key path) and `ansible/inventory/group_vars/workstation.yml` (with the public key). Both are gitignored.

3. **Provision**

   ```sh
   cd ../ansible
   ansible-galaxy collection install -r requirements.yml   # first time only
   ansible-playbook site.yml
   ```

4. **Connect**

   ```sh
   ssh dusan@$(cd ../terraform && terraform output -raw ipv4_address)
   ```

5. **Tear down**

   ```sh
   cd terraform && terraform destroy
   ```

## Notes / caveats

- **No passwords.** Login is SSH-key only and `sudo` is passwordless — the box is reached solely via the key given to Terraform. Guard that private key accordingly.
- **Fedora 44 image slug.** `var.image` defaults to `fedora-44`. Confirm it exists for your project/region with `hcloud image list`. If not, override `image` in `terraform.tfvars` or point it at a snapshot ID.
- **Server type fallback.** `var.server_types` is an ordered preference list (default `["cx23", "cx33"]`). Terraform checks which types are available for new servers in `var.location` and picks the first available one; if none are, `apply` fails with a clear message. The chosen type is shown by `terraform output selected_server_type`.
- **State is local.** `terraform.tfstate` lives on disk (gitignored). Fine for personal/ephemeral use.
- **Adding repos or packages** is a data change: append to `workstation_repositories` (repositories role), `workstation_packages` (packages role), or `workstation_directories` (directories role) — no task edits needed.
