##############################################################################
# Outputs
##############################################################################

output "restored_file_storage" {
  value       = module.restored_file_storage.file_share
  description = "restored file storage details"
}

output "mount_targets" {
  value       = module.restored_file_storage.mount_targets
  description = "Mount target details"
}
