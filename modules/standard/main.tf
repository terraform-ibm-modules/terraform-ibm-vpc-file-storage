##############################################################################
# Create File Share
##############################################################################

resource "ibm_is_share" "share" {
  depends_on                       = [time_sleep.wait_for_authorization_policy]
  name                             = var.name
  profile                          = var.profile
  size                             = var.size
  iops                             = var.iops
  resource_group                   = var.resource_group_id
  zone                             = var.zone
  encryption_key                   = var.kms_encryption_enabled ? var.kms_key_crn : null
  tags                             = var.tags
  access_tags                      = var.access_tags
  allowed_transit_encryption_modes = var.access_control_mode == "security_group" ? ["ipsec", "none"] : null
  access_control_mode              = var.access_control_mode
  allowed_access_protocols         = [var.allowed_access_protocols]
  dynamic "initial_owner" {
    for_each = (var.initial_owner_uid != null || var.initial_owner_gid != null) ? [1] : []
    content {
      uid = var.initial_owner_uid
      gid = var.initial_owner_gid
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
  existing_kms_guid  = local.create_auth_policy ? module.existing_kms_key_crn_parser[0].service_instance : null
  kms_service_name   = local.create_auth_policy ? module.existing_kms_key_crn_parser[0].service_name : null
  kms_account_id     = local.create_auth_policy ? module.existing_kms_key_crn_parser[0].account_id : null
  kms_key_id         = local.create_auth_policy ? module.existing_kms_key_crn_parser[0].resource : null
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
  count           = local.create_auth_policy ? 1 : 0
  depends_on      = [ibm_iam_authorization_policy.file_share_policy[0]]
  create_duration = "30s"
}
