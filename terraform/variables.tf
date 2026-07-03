variable "hcloud_token" {
  description = "Hetzner Cloud API token."
  type        = string
  sensitive   = true
}

variable "image" {
  description = "OS image slug. Verify it exists with `hcloud image list`."
  type        = string
  default     = "fedora-44"
}

variable "server_types" {
  description = "Preferred server types in priority order. The first one available for new servers in var.location is used."
  type        = list(string)
  default     = ["cx23", "cx33"]
}

variable "location" {
  description = "Hetzner datacenter location (e.g. nbg1, fsn1, hel1)."
  type        = string
  default     = "nbg1"
}

variable "server_name" {
  description = "Name for the server resource."
  type        = string
  default     = "ephemeral-workstation"
}

variable "ssh_public_key" {
  description = "SSH public key string. Injected for root bootstrap and reused by Ansible for the workstation user."
  type        = string
}
