output "ipv4_address" {
  description = "Public IPv4 address of the workstation."
  value       = hcloud_server.workstation.ipv4_address
}

output "ssh_command" {
  description = "Ready-to-copy SSH command for root bootstrap."
  value       = "ssh root@${hcloud_server.workstation.ipv4_address}"
}
