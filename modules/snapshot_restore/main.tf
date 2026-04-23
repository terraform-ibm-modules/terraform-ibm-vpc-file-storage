##############################################################################
# Handle File Share snapshot
##############################################################################

locals {
  use_snapshot_name = var.snapshot_restore != null && try(var.snapshot_restore.snapshot_name, null) != null
  use_snapshot_id   = var.snapshot_restore != null && try(var.snapshot_restore.snapshot_id, null) != null
  use_snapshot_crn  = var.snapshot_restore != null && try(var.snapshot_restore.snapshot_crn, null) != null

  create_if_missing = local.use_snapshot_name && try(var.snapshot_restore.create_snapshot_if_missing, false)
  source_share_id   = var.source_id != null ? var.source_id : module.share_crn_parser[0].resource
}

module "share_crn_parser" {
  count   = var.source_crn != null ? 1 : 0
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.4.1"
  crn     = var.source_crn
}

data "ibm_is_share" "source" {
  count = local.use_snapshot_name ? 1 : 0
  share = local.source_share_id
}

locals {
  source_access_control_mode = try(data.ibm_is_share.source[0].access_control_mode, null)
  is_security_group          = local.source_access_control_mode == "security_group"
}

data "ibm_is_share_snapshots" "existing" {
  count = local.use_snapshot_name && local.is_security_group ? 1 : 0
  share = local.source_share_id
}

locals {
  matching_snapshot = local.use_snapshot_name && local.is_security_group ? one([
    for s in try(data.ibm_is_share_snapshots.existing[0].snapshots, []) : s
    if try(s.name, null) == var.snapshot_restore.snapshot_name
  ]) : null

  snapshot_exists = local.matching_snapshot != null

  create_snapshot = local.use_snapshot_name && local.is_security_group && local.create_if_missing

  snapshot_crn_to_restore = (
    local.use_snapshot_crn ? var.snapshot_restore.snapshot_crn :
    local.snapshot_exists ? local.matching_snapshot.crn :
    local.create_snapshot ? try(ibm_is_share_snapshot.snapshot[0].crn, null) :
    null
  )

  snapshot_id_to_restore = (
    local.use_snapshot_id ? var.snapshot_restore.snapshot_id :
    null
  )
}

resource "ibm_is_share_snapshot" "snapshot" {
  count = local.create_snapshot ? 1 : 0
  name  = var.snapshot_restore.snapshot_name
  share = local.source_share_id

  lifecycle {
    precondition {
      condition     = local.is_security_group
      error_message = "Source share access_control_mode must be \"security_group\" ."
    }
  }
}

##############################################################################
# Create File Share restored from snapshot
##############################################################################

resource "ibm_is_share" "restored_file_storage" {
  depends_on               = [time_sleep.wait_for_authorization_policy]
  name                     = var.name
  profile                  = var.profile
  size                     = var.size
  iops                     = var.iops
  resource_group           = var.resource_group_id
  encryption_key           = var.kms_encryption_enabled ? var.kms_key_crn : null
  tags                     = var.tags
  access_tags              = var.access_tags
  allowed_access_protocols = ["nfs4"]

  dynamic "initial_owner" {
    for_each = (var.initial_owner_uid != null || var.initial_owner_gid != null) ? [1] : []
    content {
      uid = var.initial_owner_uid
      gid = var.initial_owner_gid
    }
  }

  dynamic "source_snapshot" {
    for_each = local.snapshot_crn_to_restore != null || local.snapshot_id_to_restore != null ? [1] : []
    content {
      crn = local.snapshot_crn_to_restore
      id  = local.snapshot_id_to_restore
    }
  }

  lifecycle {
    precondition {
      condition     = local.is_security_group
      error_message = "restore from snapshot requires source share access_control_mode = \"security_group\" ."
    }
  }
}
########################################################################################################################
# KMS IAM Authorization Policies
########################################################################################################################

module "existing_kms_key_crn_parser" {
  count   = local.create_auth_policy ? 1 : 0
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.4.1"
  crn     = var.kms_key_crn
}

locals {
  existing_kms_guid  = local.create_auth_policy ? null : module.existing_kms_key_crn_parser[0].service_instance
  kms_service_name   = local.create_auth_policy ? null : module.existing_kms_key_crn_parser[0].service_name
  kms_account_id     = local.create_auth_policy ? null : module.existing_kms_key_crn_parser[0].account_id
  kms_key_id         = local.create_auth_policy ? null : module.existing_kms_key_crn_parser[0].resource
  create_auth_policy = var.kms_encryption_enabled && !var.skip_iam_share_authorization_policy
}

resource "ibm_iam_authorization_policy" "file_share_policy" {
  count                = local.create_auth_policy ? 1 : 0
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
