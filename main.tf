locals {
  is_replica_enabled = (local.is_standard && var.replica != null)
  is_snapshot        = var.create_share.mode == "snapshot"
  is_accessor        = var.create_share.mode == "accessor"
  is_standard        = var.create_share.mode == "standard"
}
##############################################################################
# Create File Share
##############################################################################

resource "ibm_is_share" "share" {
  name           = var.name
  profile        = !local.is_accessor ? var.profile : null
  size           = !local.is_accessor ? var.size : null
  iops           = !local.is_accessor ? var.iops : null
  resource_group = var.resource_group_id
  zone           = local.is_standard ? var.zone : null

  encryption_key = var.kms_encryption_enabled ? var.encryption_key_crn : null
  tags           = var.tags
  access_tags    = var.access_tags

  allowed_transit_encryption_modes = local.is_standard && length(var.sg_mount_targets) > 0 ? ["ipsec", "none"] : null
  access_control_mode              = local.is_standard ? (length(var.sg_mount_targets) > 0 ? "security_group" : "vpc") : null
  allowed_access_protocols         = !local.is_accessor ? ["nfs4"] : null
  dynamic "initial_owner" {
    for_each = (var.initial_owner_uid != null || var.initial_owner_gid != null) && !local.is_accessor ? [1] : []
    content {
      uid = var.initial_owner_uid
      gid = var.initial_owner_gid
    }
  }

  dynamic "source_snapshot" {
    for_each = local.is_snapshot ? [var.create_share.source_snapshot] : []
    content {
      crn = try(source_snapshot.value.crn, null)
      id  = try(source_snapshot.value.id, null)
    }
  }

  dynamic "origin_share" {
    for_each = local.is_accessor ? [var.create_share.origin_share] : []
    content {
      crn = try(origin_share.value.crn, null)
      id  = try(origin_share.value.id, null)
    }
  }

}


#create replica
resource "ibm_is_share" "replica" {
  count                 = local.is_replica_enabled ? 1 : 0
  zone                  = var.replica.zone
  source_share          = ibm_is_share.share.id
  name                  = var.replica.name
  profile               = var.profile
  replication_cron_spec = var.replica.cron_spec
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
  create_auth_policy = !var.kms_encryption_enabled || var.skip_iam_share_authorization_policy
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
  create_mount_targets = local.is_standard || local.is_accessor
  mount_targets = local.create_mount_targets ? merge(
    {
      for idx, vpc_id in var.vpc_mount_targets :
      "vpc-${idx}" => {
        type   = "vpc"
        vpc_id = vpc_id
      }
    },
    {
      for idx, mt in var.sg_mount_targets :
      "sg-${idx}" => {
        type               = "sg"
        subnet_id          = mt.subnet_id
        security_group_ids = mt.security_group_ids
        transit_encryption = try(mt.transit_encryption, "none")
      }
    }
  ) : {}
}

resource "ibm_is_share_mount_target" "mount_targets" {
  for_each = local.mount_targets

  share           = ibm_is_share.share.id
  name            = format("%s-mount-target-%s", var.name, each.key)
  access_protocol = try(each.value.access_protocol, "nfs4")

  vpc = each.value.type == "vpc" ? each.value.vpc_id : null

  transit_encryption = each.value.type == "sg" ? each.value.transit_encryption : null

  dynamic "virtual_network_interface" {
    for_each = each.value.type == "sg" ? [1] : []
    content {
      # If using existing VNI
      id = try(each.value.vni_id, null)

      # If creating VNI
      name            = try(each.value.vni_id, null) == null ? format("%s-fs-vni-%s", var.name, each.key) : null
      subnet          = try(each.value.subnet_id, null)
      resource_group  = try(each.value.resource_group_id, null)
      security_groups = try(each.value.security_group_ids, null)

      protocol_state_filtering_mode = try(each.value.protocol_state_filtering_mode, null)

      dynamic "primary_ip" {
        for_each = try(each.value.primary_ip, null) != null && try(each.value.vni_id, null) == null ? [1] : []
        content {
          reserved_ip = try(each.value.primary_ip.reserved_ip, null)
          auto_delete = try(each.value.primary_ip.auto_delete, null)
          address     = try(each.value.primary_ip.address, null)
          name        = try(each.value.primary_ip.name, null)
        }
      }
    }
  }
}
