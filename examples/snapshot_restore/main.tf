##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.6.1"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

#############################################################################
# Create File Storage with VPC Access control mode
#############################################################################

module "restored_file_storage" {
  source = "../../modules/snapshot_restore"
  # remove the above line and uncomment the below 2 lines to consume the module from the registry
  # source                 = "terraform-ibm-modules/vpc-file-storage/ibm//modules/snapshot_restore"
  # version                = "X.Y.Z" # Replace "X.Y.Z" with a release version to lock into a specific release
  name                     = "${var.prefix}-restored"
  tags                     = var.resource_tags
  access_tags              = var.access_tags
  allowed_access_protocols = "nfs4"
  resource_group_id        = module.resource_group.resource_group_id
  source_crn               = var.existing_fileshare_crn
  size                     = 10
  iops                     = 100
  initial_owner_gid        = 100
  initial_owner_uid        = 10000
  snapshot_restore = {
    snapshot_name              = "snap1"
    create_snapshot_if_missing = true
  }
}
