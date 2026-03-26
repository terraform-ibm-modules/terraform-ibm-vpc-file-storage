output "file_share" {
  value       = module.file_storage.file_share
  description = "File share details"
}

output "replica" {
  value       = module.replica.replica
  description = "replica details"
}
output "mount_targets" {
  value       = module.file_storage.mount_targets
  description = "Mount target details"
}
output "vpc" {
  value       = module.vpc
  description = "VPC module values"
}
