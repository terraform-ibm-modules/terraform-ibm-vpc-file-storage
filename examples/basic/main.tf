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

locals {
  network_acls = [
    {
      name                         = "vpc-acl"
      add_ibm_cloud_internal_rules = true
      add_vpc_connectivity_rules   = true
      prepend_ibm_rules            = true
      rules = [
        {
          name      = "allow-all-22-inbound"
          action    = "allow"
          direction = "inbound"
          tcp = {
            port_min = 22
            port_max = 22
          }
          destination = "0.0.0.0/0"
          source      = "0.0.0.0/0"
        },
        {
          name      = "allow-all-22-inbound-response"
          action    = "allow"
          direction = "outbound"
          tcp = {
            source_port_min = 22
            source_port_max = 22
          }
          destination = "0.0.0.0/0"
          source      = "0.0.0.0/0"
        },
        {
          name      = "allow-https-outbound"
          action    = "allow"
          direction = "outbound"
          tcp = {
            port_min = 443
            port_max = 443
          }
          destination = "0.0.0.0/0"
          source      = "0.0.0.0/0"
        },
        {
          name      = "allow-https-outbound-response"
          action    = "allow"
          direction = "inbound"
          tcp = {
            source_port_min = 443
            source_port_max = 443
          }
          destination = "0.0.0.0/0"
          source      = "0.0.0.0/0"
        },
        {
          name      = "allow-http-outbound"
          action    = "allow"
          direction = "outbound"
          tcp = {
            port_min = 80
            port_max = 80
          }
          destination = "0.0.0.0/0"
          source      = "0.0.0.0/0"
        },
        {
          name      = "allow-http-outbound-response"
          action    = "allow"
          direction = "inbound"
          tcp = {
            source_port_min = 80
            source_port_max = 80
          }
          destination = "0.0.0.0/0"
          source      = "0.0.0.0/0"
        },
        {
          name      = "allow-nfs-outbound"
          action    = "allow"
          direction = "outbound"
          tcp = {
            port_min = 2049
            port_max = 2049
          }
          destination = "0.0.0.0/0"
          source      = "0.0.0.0/0"
        },
        {
          name      = "allow-nfs-outbound-response"
          action    = "allow"
          direction = "inbound"
          tcp = {
            source_port_min = 2049
            source_port_max = 2049
          }
          destination = "0.0.0.0/0"
          source      = "0.0.0.0/0"
        }
      ]
    }
  ]
}

#############################################################################
# Provision VPC
#############################################################################

module "vpc" {
  source            = "terraform-ibm-modules/landing-zone-vpc/ibm"
  version           = "9.1.0"
  resource_group_id = module.resource_group.resource_group_id
  region            = var.region
  prefix            = var.prefix
  tags              = var.resource_tags
  name              = "vpc"
  subnets = {
    zone-1 = [
      {
        name           = "subnet-a"
        cidr           = "10.10.10.0/24"
        public_gateway = true
        acl_name       = "vpc-acl"
        no_addr_prefix = false
      }
  ] }
  network_acls = local.network_acls
}

#############################################################################
# Create File Storage with VPC Access control mode
#############################################################################

module "file_storage" {
  source = "../../"
  # remove the above line and uncomment the below 2 lines to consume the module from the registry
  # source                            = "terraform-ibm-modules/vpc-file-storage/ibm/"
  # version                           = "X.Y.Z" # Replace "X.Y.Z" with a release version to lock into a specific release
  name                                = "${var.prefix}-basic-share"
  resource_group_id                   = module.resource_group.resource_group_id
  size                                = 10
  iops                                = 100
  initial_owner_gid                   = 100
  initial_owner_uid                   = 10000
  allowed_access_protocols            = "nfs4"
  zone                                = "${var.region}-1"
  kms_encryption_enabled              = var.kms_encryption_enabled
  skip_iam_share_authorization_policy = var.skip_iam_share_authorization_policy
  kms_key_crn                         = var.kms_key_crn
  vpc_mount_targets = {
    "primary" = {
      name   = "${var.prefix}-vpc-target"
      vpc_id = module.vpc.vpc_id
    }
  }
}

module "replica" {
  source = "../../"
  # remove the above line and uncomment the below 2 lines to consume the module from the registry
  # source          = "terraform-ibm-modules/vpc-file-storage/ibm/"
  # version         = "X.Y.Z" # Replace "X.Y.Z" with a release version to lock into a specific release
  mode        = "replica"
  tags        = var.resource_tags
  access_tags = var.access_tags
  name        = "${var.prefix}-replica"
  zone        = "${var.region}-2"
  source_crn  = module.file_storage.file_share.crn
  iops        = module.file_storage.file_share.iops
  cron_spec   = "0 */5 * * *"
  vpc_mount_targets = {
    "primary" = {
      name   = "${var.prefix}-vpc-target"
      vpc_id = module.vpc.vpc_id
    }
  }
}
