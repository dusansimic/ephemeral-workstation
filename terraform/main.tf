resource "hcloud_ssh_key" "this" {
  name       = "${var.server_name}-key"
  public_key = var.ssh_public_key
}

resource "hcloud_server" "workstation" {
  name        = var.server_name
  image       = var.image
  server_type = var.server_type
  location    = var.location
  ssh_keys    = [hcloud_ssh_key.this.id]

  labels = {
    role = "ephemeral-workstation"
  }
}

# Generate the Ansible inventory from the created server's public IP.
resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory/hosts.ini"
  content = templatefile("${path.module}/templates/inventory.tmpl", {
    ipv4_address = hcloud_server.workstation.ipv4_address
  })
  file_permission = "0644"
}
