##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.5.0"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

locals {
  prefix = var.prefix != null && trimspace(var.prefix) != "" ? trimspace(var.prefix) : ""
}

##############################################################################
# Cross account share broker auth policy
##############################################################################

module "share_crn_parser" {
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.4.1"
  crn     = var.existing_fileshare_crn
}

data "ibm_iam_account_settings" "origin" {
  provider = ibm
}
# Accessor/consumer account
data "ibm_iam_account_settings" "accessor" {
  provider = ibm.accessor
}

resource "ibm_iam_authorization_policy" "share_broker_cross_account" {

  # SUBJECT (accessor account)
  subject_attributes {
    name  = "accountId"
    value = data.ibm_iam_account_settings.accessor.account_id
  }

  subject_attributes {
    name  = "serviceName"
    value = "is"
  }

  subject_attributes {
    name  = "resourceType"
    value = "share"
  }

  # RESOURCE (origin account)
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
    value    = module.share_crn_parser.resource
  }

  roles = ["Share Broker"]
}

resource "time_sleep" "wait_for_share_broker_policy" {
  depends_on      = [ibm_iam_authorization_policy.share_broker_cross_account]
  create_duration = "30s"
}


#############################################################################
# Create an Accessor binding to File Storage in another account
#############################################################################

module "accessor" {
  providers = {
    ibm = ibm.accessor
  }
  source = "../../"
  # remove the above line and uncomment the below 2 lines to consume the module from the registry
  # source   = "terraform-ibm-modules/vpc-file-storage/ibm/"
  # version  = "X.Y.Z" # Replace "X.Y.Z" with a release version to lock into a specific release
  depends_on  = [time_sleep.wait_for_share_broker_policy]
  tags        = var.resource_tags
  access_tags = var.access_tags
  mode        = "accessor"
  name        = "${local.prefix}-aces-bind"
  crn         = var.existing_fileshare_crn
}
