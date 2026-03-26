output "file_share" {
  value       = module.file_storage.file_share
  description = "File share details"
}

output "mount_targets" {
  value       = module.file_storage.mount_targets
  description = "Mount target details"
}

output "cross_regional_replica" {
  value       = module.cross_regional_replica.replica
  description = "Cross Regional Replica details"
}

output "vsi_security_group" {
  description = "Security group for the VSI."
  value       = module.vsi.vsi_security_group
}

output "vsi_data" {
  description = "A list of VSI with name, id, zone, and primary ipv4 address."
  value       = module.vsi.list
}

##############################################################################
# SSH Key
##############################################################################

output "ssh_private_key" {
  value       = tls_private_key.tls_key.private_key_pem
  description = "The ssh private key data in [PEM (RFC 1421)](https://datatracker.ietf.org/doc/html/rfc1421) format."
  sensitive   = true
}
