##############################################################################
# Create Replica File Share
##############################################################################

resource "ibm_is_share" "replica" {
  depends_on            = [time_sleep.wait_for_authorization_policy]
  name                  = var.name
  profile               = var.profile
  zone                  = var.zone
  iops                  = var.iops
  encryption_key        = var.cross_regional_replica ? var.kms_key_crn : null
  tags                  = var.tags
  access_tags           = var.access_tags
  replication_cron_spec = var.cron_spec
  source_share_crn      = var.source_crn
}

##############################################################################
# Cross Regional Replica File Share Auth Policy
##############################################################################

data "ibm_iam_account_settings" "origin" {}

module "share_crn_parser" {
  count   = var.cross_regional_replica ? 1 : 0
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.5.0"
  crn     = var.source_crn
}

resource "ibm_iam_authorization_policy" "cross_regional_replica_policy" {
  count                = var.cross_regional_replica == true ? 1 : 0
  source_service_name  = "is"
  source_resource_type = "share"
  roles                = ["Editor"]
  resource_attributes {
    name  = "accountId"
    value = data.ibm_iam_account_settings.origin.account_id
  }
  resource_attributes {
    name  = "serviceName"
    value = "is"
  }

  resource_attributes {
    name     = "shareId"
    operator = "stringEquals"
    value    = module.share_crn_parser[0].resource
  }
}
resource "time_sleep" "wait_for_authorization_policy" {
  count           = var.cross_regional_replica ? 1 : 0
  depends_on      = [ibm_iam_authorization_policy.cross_regional_replica_policy]
  create_duration = "30s"
}
