output "id" {
  description = "The unique identifier of the file share."
  value       = ibm_is_share.share.id
}

output "crn" {
  description = "The Cloud Resource Name (CRN) of the file share."
  value       = ibm_is_share.share.crn
}

output "href" {
  description = "The URL (href) of the file share."
  value       = ibm_is_share.share.href
}

output "name" {
  description = "The unique name of the file share within the region."
  value       = ibm_is_share.share.name
}

output "zone" {
  description = "The zone in which the file share resides."
  value       = ibm_is_share.share.zone
}

output "profile" {
  description = "The storage profile used by the file share."
  value       = ibm_is_share.share.profile
}

output "size" {
  description = "The capacity of the file share in GB."
  value       = ibm_is_share.share.size
}

output "iops" {
  description = "The maximum IOPS for the file share."
  value       = ibm_is_share.share.iops
}

output "access_control_mode" {
  description = "The access control mode for the file share."
  value       = ibm_is_share.share.access_control_mode
}

output "access_tags" {
  description = "Access management tags associated with the file share."
  value       = ibm_is_share.share.access_tags
}

output "allowed_transit_encryption_modes" {
  description = "The transit encryption modes allowed for this file share."
  value       = ibm_is_share.share.allowed_transit_encryption_modes
}

output "encryption" {
  description = "The type of encryption used for this file share."
  value       = ibm_is_share.share.encryption
}

output "created_at" {
  description = "The RFC3339 timestamp when the file share was created."
  value       = ibm_is_share.share.created_at
}

output "lifecycle_state" {
  description = "The lifecycle state of the file share."
  value       = ibm_is_share.share.lifecycle_state
}

output "resource_type" {
  description = "The resource type of the file share."
  value       = ibm_is_share.share.resource_type
}

output "resource_group" {
  description = "The resource group ID that owns the file share."
  value       = ibm_is_share.share.resource_group
}

output "tags" {
  description = "User tags associated with the file share."
  value       = ibm_is_share.share.tags
}
