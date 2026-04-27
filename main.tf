##############################################################################
# Create File Share
##############################################################################

module "standard" {
  count                               = var.mode == "standard" ? 1 : 0
  source                              = "./modules/standard"
  name                                = var.name
  profile                             = var.profile
  size                                = var.size
  iops                                = var.iops
  resource_group_id                   = var.resource_group_id
  zone                                = var.zone
  kms_encryption_enabled              = var.kms_encryption_enabled
  skip_iam_share_authorization_policy = var.skip_iam_share_authorization_policy
  kms_key_crn                         = var.kms_key_crn
  tags                                = var.tags
  access_tags                         = var.access_tags
  access_control_mode                 = length(var.sg_mount_targets) > 0 ? "security_group" : "vpc"
  initial_owner_gid                   = var.initial_owner_gid
  initial_owner_uid                   = var.initial_owner_uid
  allowed_access_protocols            = var.allowed_access_protocols
}

module "replica" {
  count                  = var.mode == "replica" ? 1 : 0
  source                 = "./modules/replica"
  name                   = var.name
  profile                = var.profile
  zone                   = var.zone
  iops                   = var.iops
  cross_regional_replica = var.cross_regional_replica
  kms_key_crn            = var.cross_regional_replica ? var.kms_key_crn : null
  tags                   = var.tags
  access_tags            = var.access_tags
  cron_spec              = var.cron_spec
  source_id              = var.id
  source_crn             = var.crn
}

module "snapshot_restore" {
  count                               = var.mode == "snapshot_restore" ? 1 : 0
  source                              = "./modules/snapshot_restore"
  name                                = var.name
  profile                             = var.profile
  size                                = var.size
  iops                                = var.iops
  resource_group_id                   = var.resource_group_id
  kms_encryption_enabled              = var.kms_encryption_enabled
  skip_iam_share_authorization_policy = var.skip_iam_share_authorization_policy
  kms_key_crn                         = var.kms_key_crn
  tags                                = var.tags
  access_tags                         = var.access_tags
  initial_owner_gid                   = var.initial_owner_gid
  initial_owner_uid                   = var.initial_owner_uid
  snapshot_restore                    = var.snapshot_restore
  source_crn                          = var.crn
  source_id                           = var.id
  allowed_access_protocols            = var.allowed_access_protocols
}

module "accessor" {
  count       = var.mode == "accessor" ? 1 : 0
  source      = "./modules/accessor"
  name        = var.name
  tags        = var.tags
  access_tags = var.access_tags
  source_crn  = var.crn
  source_id   = var.id
}

##############################################################################
# Create Mount Targets For File Share
##############################################################################

locals {
  active_share_id = (
    var.mode == "standard" ? module.standard[0].id :
    var.mode == "accessor" ? module.accessor[0].id :
    var.mode == "replica" ? module.replica[0].id :
    var.mode == "snapshot_restore" ? module.snapshot_restore[0].id :
    null
  )
  mount_targets = merge(
    {
      for k, mt in var.vpc_mount_targets :
      "vpc-${k}" => {
        type   = "vpc"
        name   = mt.name
        vpc_id = mt.vpc_id
      }
    },
    {
      for k, mt in var.sg_mount_targets :
      "sg-${k}" => merge(
        {
          type = "sg"
        },
        mt
      )
    }
  )
}

resource "ibm_is_share_mount_target" "mount_targets" {
  for_each           = local.mount_targets
  share              = local.active_share_id
  name               = each.value.name
  access_protocol    = try(each.value.access_protocol, "nfs4")
  vpc                = each.value.type == "vpc" ? each.value.vpc_id : null
  transit_encryption = each.value.type == "sg" ? try(each.value.transit_encryption, "none") : null

  dynamic "virtual_network_interface" {
    for_each = each.value.type == "sg" ? [1] : []
    content {
      # If using existing VNI
      id = each.value.vni_id

      # If creating VNI
      name = each.value.vni_id == null ? format("%s-fs-vni-%s", var.name, each.key) : null

      subnet          = each.value.vni_id == null ? each.value.subnet_id : null
      resource_group  = each.value.vni_id == null ? each.value.resource_group_id : null
      security_groups = each.value.vni_id == null ? each.value.security_group_ids : null

      protocol_state_filtering_mode = each.value.vni_id == null ? each.value.protocol_state_filtering_mode : null

      dynamic "primary_ip" {
        for_each = each.value.vni_id == null && each.value.primary_ip != null ? [1] : []
        content {
          reserved_ip = each.value.primary_ip.reserved_ip
          auto_delete = each.value.primary_ip.reserved_ip == null ? each.value.primary_ip.auto_delete : null
          address     = each.value.primary_ip.reserved_ip == null ? each.value.primary_ip.address : null
          name        = each.value.primary_ip.reserved_ip == null ? each.value.primary_ip.name : null
        }
      }
    }
  }
}
