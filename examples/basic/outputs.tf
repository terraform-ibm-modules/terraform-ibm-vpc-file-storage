##############################################################################
# Outputs
##############################################################################
output "file_share" {
  value       = module.file_storage.file_share
  description = "Details of the file storage instance created"
}

output "replica" {
  value       = module.replica.file_share
  description = "Details of the replica of this file storage instance"
}

output "mount_targets" {
  value       = module.file_storage.mount_targets
  description = "Details of the mount targets of this file storage instance"
}

output "vpc" {
  value       = module.vpc
  description = "VPC module details"
}
