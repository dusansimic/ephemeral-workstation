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

variable "server_type" {
  description = "Hetzner server type. cx22 = 2 vCPU / 4GB (AMD, cheapest current gen)."
  type        = string
  default     = "cx22"
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
