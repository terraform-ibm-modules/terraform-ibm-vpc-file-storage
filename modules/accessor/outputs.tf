output "id" {
  description = "The unique identifier of the accessor file share."
  value       = ibm_is_share.accessor.id
}

output "crn" {
  description = "The Cloud Resource Name (CRN) of the accessor file share."
  value       = ibm_is_share.accessor.crn
}

output "href" {
  description = "The URL (href) of the accessor file share."
  value       = ibm_is_share.accessor.href
}

output "name" {
  description = "The unique name of the accessor file share within the region."
  value       = ibm_is_share.accessor.name
}

output "zone" {
  description = "The zone in which the accessor file share resides."
  value       = ibm_is_share.accessor.zone
}

output "profile" {
  description = "The storage profile used by the accessor file share."
  value       = ibm_is_share.accessor.profile
}

output "size" {
  description = "The capacity of the accessor file share in GB."
  value       = ibm_is_share.accessor.size
}

output "iops" {
  description = "The maximum IOPS for the accessor file share."
  value       = ibm_is_share.accessor.iops
}

output "access_control_mode" {
  description = "The access control mode for the accessor file share."
  value       = ibm_is_share.accessor.access_control_mode
}

output "access_tags" {
  description = "Access management tags associated with the accessor file share."
  value       = ibm_is_share.accessor.access_tags
}

output "allowed_transit_encryption_modes" {
  description = "The transit encryption modes allowed for this accessor file share."
  value       = ibm_is_share.accessor.allowed_transit_encryption_modes
}

output "encryption" {
  description = "The type of encryption used for this accessor file share."
  value       = ibm_is_share.accessor.encryption
}

output "created_at" {
  description = "The RFC3339 timestamp when the accessor file share was created."
  value       = ibm_is_share.accessor.created_at
}

output "source_snapshot" {
  description = "The origin share this accessor share is referring to."
  value       = ibm_is_share.accessor.source_snapshot
}

output "lifecycle_state" {
  description = "The lifecycle state of the accessor file share."
  value       = ibm_is_share.accessor.lifecycle_state
}

output "resource_type" {
  description = "The resource type of the accessor file share."
  value       = ibm_is_share.accessor.resource_type
}

output "resource_group" {
  description = "The resource group ID that owns the accessor file share."
  value       = ibm_is_share.accessor.resource_group
}

output "tags" {
  description = "User tags associated with the accessor file share."
  value       = ibm_is_share.accessor.tags
}
