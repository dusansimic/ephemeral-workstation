output "ipv4_address" {
  description = "Public IPv4 address of the workstation."
  value       = hcloud_server.workstation.ipv4_address
}

output "selected_server_type" {
  description = "Server type chosen from the preference list (first available in the location)."
  value       = local.selected_server_type
}

output "ssh_command" {
  description = "Ready-to-copy SSH command for root bootstrap."
  value       = "ssh root@${hcloud_server.workstation.ipv4_address}"
}
