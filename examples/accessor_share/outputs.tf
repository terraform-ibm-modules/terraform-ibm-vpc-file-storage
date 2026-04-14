##############################################################################
# Outputs
##############################################################################

output "accessor_share" {
  value       = module.accessor.file_share
  description = "accessor file storage instance details"
}

output "mount_targets" {
  value       = module.accessor.mount_targets
  description = "Details of the mount targets of this accessor file storage instance"
}
