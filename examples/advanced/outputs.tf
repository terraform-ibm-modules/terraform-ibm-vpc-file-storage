output "file_share" {
  value       = module.file_storage.file_share
  description = "File share details"
}

output "mount_targets" {
  value       = module.file_storage.mount_targets
  description = "Mount target details"
}

output "cross_regional_replica" {
  value = {
    id                    = ibm_is_share.cross_regional_replica.id
    crn                   = ibm_is_share.cross_regional_replica.crn
    name                  = ibm_is_share.cross_regional_replica.name
    zone                  = ibm_is_share.cross_regional_replica.zone
    profile               = ibm_is_share.cross_regional_replica.profile
    replication_cron_spec = ibm_is_share.cross_regional_replica.replication_cron_spec
    source_share          = ibm_is_share.cross_regional_replica.source_share
  }
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

output "fip_list" {
  description = "A list of VSI with name, id, zone, and primary ipv4 address, and floating IP. This list only contains instances with a floating IP attached."
  value       = length(module.vsi.fip_list) > 0 ? module.vsi.fip_list : null
}

##############################################################################
# SSH Key
##############################################################################

output "ssh_private_key" {
  value       = tls_private_key.tls_key.private_key_pem
  description = "The ssh private key data in [PEM (RFC 1421)](https://datatracker.ietf.org/doc/html/rfc1421) format."
  sensitive   = true
}
