output "id" {
  description = "The unique identifier of the replica file share"
  value       = ibm_is_share.replica.id
}

output "crn" {
  description = "The Cloud Resource Name (CRN) of the replica file share"
  value       = ibm_is_share.replica.crn
}

output "href" {
  description = "The URL (href) of the replica file share"
  value       = ibm_is_share.replica.href
}

output "name" {
  description = "The unique name of the replica file share within the region."
  value       = ibm_is_share.replica.name
}

output "zone" {
  description = "The zone in which the replica file share resides."
  value       = ibm_is_share.replica.zone
}

output "profile" {
  description = "The storage profile used by the replica file share."
  value       = ibm_is_share.replica.profile
}

output "size" {
  description = "The capacity of the replica file share in GB."
  value       = ibm_is_share.replica.size
}

output "iops" {
  description = "The maximum IOPS for the replica file share"
  value       = ibm_is_share.replica.iops
}

output "access_control_mode" {
  description = "The access control mode for the replica file share"
  value       = ibm_is_share.replica.access_control_mode
}

output "access_tags" {
  description = "Access management tags associated with the replica file share"
  value       = ibm_is_share.replica.access_tags
}

output "allowed_transit_encryption_modes" {
  description = "The transit encryption modes allowed for this file share."
  value       = ibm_is_share.replica.allowed_transit_encryption_modes
}

output "encryption" {
  description = "The type of encryption used for this file share."
  value       = ibm_is_share.replica.encryption
}

output "created_at" {
  description = "The RFC3339 timestamp when the replica file share was created."
  value       = ibm_is_share.replica.created_at
}

output "lifecycle_state" {
  description = "The lifecycle state of the replica file share."
  value       = ibm_is_share.replica.lifecycle_state
}

output "resource_type" {
  description = "The resource type of the replica file share"
  value       = ibm_is_share.replica.resource_type
}

output "resource_group" {
  description = "The resource group ID that owns the replica file share"
  value       = ibm_is_share.replica.resource_group
}

output "tags" {
  description = "User tags associated with the replica file share"
  value       = ibm_is_share.replica.tags
}
