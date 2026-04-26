output "file_share_crn" {
  value       = module.file_storage.file_share.crn
  description = "file storage instance crn."
}

output "mount_targets" {
  value       = module.file_storage.mount_targets
  description = "Details of the mount targets of this file storage instance"
}

output "vsi_security_group_id" {
  description = "Security group ID for the VSI."
  value       = module.vsi.vsi_security_group.id
}
