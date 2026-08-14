#######################################################################################################################
# Resource Group
#######################################################################################################################
module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.6.1"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

locals {
  ssh_key_id = resource.ibm_is_ssh_key.ssh_key.id
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
  security_group = {
    name = "ssh-security-group"
    rules = [
      {
        name      = "allow-ssh-inbound"
        direction = "inbound"
        source    = "0.0.0.0/0"
        tcp = {
          port_min = 22
          port_max = 22
        }
      },
      {
        name      = "allow-http-outbound"
        direction = "outbound"
        source    = "0.0.0.0/0"
        tcp = {
          port_min = 80
          port_max = 80
        }
      },
      {
        name      = "allow-https-outbound"
        direction = "outbound"
        source    = "0.0.0.0/0"
        tcp = {
          port_min = 443
          port_max = 443
        }
      },
      {
        name      = "allow-dns-udp-outbound"
        direction = "outbound"
        source    = "0.0.0.0/0"
        udp = {
          port_min = 53
          port_max = 53
        }
      },
      {
        name      = "allow-nfs-outbound"
        direction = "outbound"
        source    = "0.0.0.0/0"
        tcp = {
          port_min = 2049
          port_max = 2049
        }
      },
      {
        name      = "allow-nfs-inbound"
        direction = "inbound"
        source    = "0.0.0.0/0"
        tcp = {
          port_min = 2049
          port_max = 2049
        }
      }
    ]
  }
}

##############################################################################
# Create new SSH key
##############################################################################

resource "tls_private_key" "tls_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "ibm_is_ssh_key" "ssh_key" {
  name       = "${var.prefix}-ssh-key"
  public_key = resource.tls_private_key.tls_key.public_key_openssh
}


#############################################################################
# Provision VPC
#############################################################################

module "vpc" {
  source            = "terraform-ibm-modules/landing-zone-vpc/ibm"
  version           = "9.2.1"
  resource_group_id = module.resource_group.resource_group_id
  region            = var.region
  prefix            = var.prefix
  resource_tags     = var.resource_tags
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
  name         = "vpc"
  network_acls = local.network_acls
}

#############################################################################
# VSI Image lookup
#############################################################################

module "vsi_image_selector" {
  source           = "terraform-ibm-modules/common-utilities/ibm//modules/vsi-image-selector"
  version          = "1.9.0"
  architecture     = "amd64"
  operating_system = "ubuntu"
}

########################################################################################################################
# Virtual Server Instance
########################################################################################################################

module "vsi" {
  source                = "terraform-ibm-modules/landing-zone-vsi/ibm"
  version               = "6.6.2"
  resource_group_id     = module.resource_group.resource_group_id
  image_id              = module.vsi_image_selector.latest_image_id
  resource_tags         = var.resource_tags
  access_tags           = var.access_tags
  subnets               = module.vpc.subnet_zone_list
  vpc_id                = module.vpc.vpc_id
  prefix                = "${var.prefix}-vsi"
  machine_type          = "bx2d-2x8"
  user_data             = null
  vsi_per_subnet        = 1
  ssh_key_ids           = [local.ssh_key_id]
  enable_floating_ip    = true
  create_security_group = true
  security_group        = local.security_group
}
#############################################################################
# Create File Storage with Security Group Access control mode
#############################################################################

module "file_storage" {
  source = "../../"
  # remove the above line and uncomment the below 2 lines to consume the module from the registry
  # source                            = "terraform-ibm-modules/vpc-file-storage/ibm/"
  # version                           = "X.Y.Z" # Replace "X.Y.Z" with a release version to lock into a specific release
  name                                = "${var.prefix}-adv-share"
  resource_group_id                   = module.resource_group.resource_group_id
  tags                                = var.resource_tags
  access_tags                         = var.access_tags
  size                                = 10
  iops                                = 100
  zone                                = "${var.region}-1"
  initial_owner_gid                   = 100
  initial_owner_uid                   = 10000
  allowed_access_protocols            = "nfs4"
  kms_encryption_enabled              = var.kms_encryption_enabled
  skip_iam_share_authorization_policy = var.skip_iam_share_authorization_policy
  kms_key_crn                         = var.kms_key_crn
  sg_mount_targets = {
    "sg-primary" = {
      name               = "${var.prefix}-sg-target"
      security_group_ids = [module.vsi.vsi_security_group.id]
      subnet_id          = module.vpc.subnet_ids[0]
    }
  }


}

module "cross_regional_replica" {
  providers = {
    ibm = ibm.replica
  }
  source = "../../"
  # remove the above line and uncomment the below 2 lines to consume the module from the registry
  # source               = "terraform-ibm-modules/vpc-file-storage/ibm/"
  # version              = "X.Y.Z" # Replace "X.Y.Z" with a release version to lock into a specific release
  mode                   = "replica"
  tags                   = var.resource_tags
  access_tags            = var.access_tags
  name                   = "${var.prefix}-replica"
  zone                   = "us-east-1"
  source_crn             = module.file_storage.file_share.crn
  iops                   = module.file_storage.file_share.iops
  cron_spec              = "0 */5 * * *"
  cross_regional_replica = true
  kms_key_crn            = var.kms_encryption_enabled ? var.kms_key_crn : null # if parent of the cross-regional replica has user managed key , it must be passed here
}
