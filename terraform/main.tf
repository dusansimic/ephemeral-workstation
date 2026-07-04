resource "hcloud_ssh_key" "this" {
  name       = "${var.server_name}-key"
  public_key = var.ssh_public_key
}

# Determine which of the preferred server types can actually be created in the
# target location, then pick the first available one (cx23, else cx33, ...).
data "hcloud_server_types" "all" {}

locals {
  # name -> is it available for new servers in var.location?
  server_type_available = {
    for t in data.hcloud_server_types.all.server_types :
    t.name => anytrue([for loc in t.locations : loc.available if loc.name == var.location])
    if contains(var.server_types, t.name)
  }

  # Preferred types that are available, in priority order.
  available_server_types = [
    for name in var.server_types : name
    if lookup(local.server_type_available, name, false)
  ]

  selected_server_type = try(local.available_server_types[0], null)
}

resource "hcloud_server" "workstation" {
  name        = var.server_name
  image       = var.image
  server_type = local.selected_server_type
  location    = var.location
  ssh_keys    = [hcloud_ssh_key.this.id]

  labels = {
    role = "ephemeral-workstation"
  }

  lifecycle {
    precondition {
      condition     = local.selected_server_type != null
      error_message = "None of the preferred server types (${join(", ", var.server_types)}) are available for new servers in location '${var.location}'. Check `hcloud server-type list` and datacenter availability."
    }
  }
}

# Generate the Ansible inventory from the created server's public IP.
resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory/hosts.ini"
  content = templatefile("${path.module}/templates/inventory.tmpl", {
    ipv4_address         = hcloud_server.workstation.ipv4_address
    ssh_private_key_file = var.ssh_private_key_file
  })
  file_permission = "0644"
}

# Generate the Ansible group_vars holding the user's SSH public key.
resource "local_file" "ansible_group_vars" {
  filename = "${path.module}/../ansible/inventory/group_vars/workstation.yml"
  content = templatefile("${path.module}/templates/group_vars.tmpl", {
    ssh_public_key = var.ssh_public_key
  })
  file_permission = "0644"
}
