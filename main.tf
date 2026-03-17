locals {
  restoring_from_snapshot = var.enable_snapshot_restore
  create_accessor_share   = var.origin_share_crn != null
  replica_enabled = (
    !local.restoring_from_snapshot &&
    var.replica_name != null &&
    var.replica_zone != null &&
    var.replica_cron_spec != null
  )
  create_file_share = var.name != null && !local.restoring_from_snapshot && !local.create_accessor_share ? 1 : 0
}
##############################################################################
# Create File Share
##############################################################################
resource "ibm_is_share" "share" {
  count                            = local.create_file_share
  name                             = var.name
  allowed_transit_encryption_modes = length(var.sg_mount_targets) > 0 ? ["ipsec", "none"] : null
  resource_group                   = var.resource_group_id
  access_control_mode              = length(var.sg_mount_targets) > 0 ? "security_group" : "vpc"
  profile                          = var.profile
  size                             = var.size
  iops                             = var.iops
  zone                             = var.zone
  encryption_key                   = var.kms_encryption_enabled ? var.encryption_key_crn : null
  tags                             = var.tags
  access_tags                      = var.access_tags
  dynamic "initial_owner" {
    for_each = (var.initial_owner_uid != null || var.initial_owner_gid != null) ? [1] : []
    content {
      uid = var.initial_owner_uid
      gid = var.initial_owner_gid
    }
  }
}
#create replica
resource "ibm_is_share" "replica" {
  count                 = local.replica_enabled && local.create_file_share == 1 ? 1 : 0
  zone                  = var.replica_zone
  source_share          = ibm_is_share.share[0].id
  name                  = var.replica_name
  profile               = var.profile
  replication_cron_spec = var.replica_cron_spec
}

#restore from snapshot
resource "ibm_is_share" "snapshot_restore" {
  count          = var.enable_snapshot_restore ? 1 : 0
  name           = var.name
  profile        = var.profile
  size           = var.size
  encryption_key = var.kms_encryption_enabled ? var.encryption_key_crn : null
  source_snapshot {
    crn = var.source_snapshot_crn
  }

}
##############################################################################
# Accessor share
##############################################################################

resource "ibm_is_share" "accessor" {
  count = local.create_accessor_share ? 1 : 0
  name  = var.name
  origin_share {
    crn = var.origin_share_crn
  }
}

########################################################################################################################
# KMS IAM Authorization Policies
########################################################################################################################
module "existing_kms_key_crn_parser" {
  count   = local.create_auth_policy ? 0 : 1
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.4.1"
  crn     = var.encryption_key_crn
}

locals {
  existing_kms_guid  = local.create_auth_policy ? null : module.existing_kms_key_crn_parser[0].service_instance
  kms_service_name   = local.create_auth_policy ? null : module.existing_kms_key_crn_parser[0].service_name
  kms_account_id     = local.create_auth_policy ? null : module.existing_kms_key_crn_parser[0].account_id
  kms_key_id         = local.create_auth_policy ? null : module.existing_kms_key_crn_parser[0].resource
  create_auth_policy = var.kms_encryption_enabled == false || var.skip_iam_share_authorization_policy
}

resource "ibm_iam_authorization_policy" "file_share_policy" {
  count                = local.create_auth_policy ? 0 : 1
  source_service_name  = "is"
  source_resource_type = "share"
  roles                = ["Reader"]
  description          = "Allow VPC file shares to read encryption key ${local.kms_key_id} from ${local.kms_service_name} instance ${local.existing_kms_guid}"
  resource_attributes {
    name     = "serviceName"
    operator = "stringEquals"
    value    = local.kms_service_name
  }
  resource_attributes {
    name     = "accountId"
    operator = "stringEquals"
    value    = local.kms_account_id
  }
  resource_attributes {
    name     = "serviceInstance"
    operator = "stringEquals"
    value    = local.existing_kms_guid
  }
  resource_attributes {
    name     = "resourceType"
    operator = "stringEquals"
    value    = "key"
  }
  resource_attributes {
    name     = "resource"
    operator = "stringEquals"
    value    = local.kms_key_id
  }
  # Scope of policy now includes the key, so ensure to create new policy before
  # destroying old one to prevent any disruption to every day services.
  lifecycle {
    create_before_destroy = true
  }
}

resource "time_sleep" "wait_for_authorization_policy" {
  count           = local.create_auth_policy ? 0 : 1
  depends_on      = [ibm_iam_authorization_policy.file_share_policy[0]]
  create_duration = "30s"
}
##############################################################################
# Create Mount Targets For File Share
##############################################################################
locals {
  create_mount_target   = local.create_file_share == 1 || local.create_accessor_share
  mount_target_share_id = try(ibm_is_share.share[0].id, ibm_is_share.accessor[0].id, null)
}

resource "ibm_is_share_mount_target" "share_target_vpc" {
  for_each = local.create_mount_target ? {
    for idx, vpc in var.vpc_mount_targets : idx => vpc
  } : {}

  share = local.mount_target_share_id
  name  = format("%s-mount-target-%d", var.name, each.key)
  vpc   = each.value
}

resource "ibm_is_share_mount_target" "share_target_sg" {
  for_each = local.create_mount_target ? {
    for idx, mt in var.sg_mount_targets : idx => mt
  } : {}

  share              = local.mount_target_share_id
  name               = format("%s-mount-target-%d", var.name, each.key)
  transit_encryption = each.value.transit_encryption

  virtual_network_interface {
    primary_ip {
      name = format("%s-fs-pip-%d", var.name, each.key)
    }
    subnet          = each.value.subnet_id
    name            = format("%s-fs-vni-%d", var.name, each.key)
    resource_group  = var.resource_group_id
    security_groups = each.value.security_group_ids
  }
}
