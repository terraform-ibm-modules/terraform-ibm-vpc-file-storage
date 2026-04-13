output "id" {
  description = "The unique identifier of the file share."
  value       = ibm_is_share.restored_file_storage.id
}

output "crn" {
  description = "The Cloud Resource Name (CRN) of the file share."
  value       = ibm_is_share.restored_file_storage.crn
}

output "href" {
  description = "The URL (href) of the file share."
  value       = ibm_is_share.restored_file_storage.href
}

output "name" {
  description = "The unique name of the file share within the region."
  value       = ibm_is_share.restored_file_storage.name
}

output "zone" {
  description = "The zone in which the file share resides."
  value       = ibm_is_share.restored_file_storage.zone
}

output "profile" {
  description = "The storage profile used by the file share."
  value       = ibm_is_share.restored_file_storage.profile
}

output "size" {
  description = "The capacity of the file share in GB."
  value       = ibm_is_share.restored_file_storage.size
}

output "iops" {
  description = "The maximum IOPS for the file share."
  value       = ibm_is_share.restored_file_storage.iops
}

output "access_control_mode" {
  description = "The access control mode for the file share."
  value       = ibm_is_share.restored_file_storage.access_control_mode
}

output "source_snapshot" {
  description = "The snapshot from which this share was cloned."
  value       = ibm_is_share.restored_file_storage.source_snapshot
}

output "access_tags" {
  description = "Access management tags associated with the file share."
  value       = ibm_is_share.restored_file_storage.access_tags
}

output "allowed_transit_encryption_modes" {
  description = "The transit encryption modes allowed for this file share."
  value       = ibm_is_share.restored_file_storage.allowed_transit_encryption_modes
}

output "encryption" {
  description = "The type of encryption used for this file share."
  value       = ibm_is_share.restored_file_storage.encryption
}

output "created_at" {
  description = "The RFC3339 timestamp when the file share was created."
  value       = ibm_is_share.restored_file_storage.created_at
}

output "lifecycle_state" {
  description = "The lifecycle state of the file share."
  value       = ibm_is_share.restored_file_storage.lifecycle_state
}

output "resource_type" {
  description = "The resource type of the file share."
  value       = ibm_is_share.restored_file_storage.resource_type
}

output "resource_group" {
  description = "The resource group ID that owns the file share."
  value       = ibm_is_share.restored_file_storage.resource_group
}

output "tags" {
  description = "User tags associated with the file share."
  value       = ibm_is_share.restored_file_storage.tags
}
