#######################################################################################################################
# Resource Group
#######################################################################################################################
module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.5.0"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

data "ibm_iam_account_settings" "origin" {
  provider = ibm
}

locals {
  ssh_key_id = resource.ibm_is_ssh_key.ssh_key.id
  prefix     = var.prefix != null ? trimspace(var.prefix) != "" ? "${var.prefix}-" : "" : ""
  user_data  = <<-EOT
    #!/bin/bash
    set -e

    cat > /etc/profile.d/welcome.sh << 'EOF'
    #!/bin/bash
    set -e

    if [ -t 0 ] && [ "$PS1" ]; then
        echo "=========================================="
        echo "Welcome to Your IBM Cloud VSI!"
        echo "=========================================="
        echo "Server Information:"
        echo "- Hostname: $(hostname)"
        echo "- IP Address: $(hostname -I | awk '{print $1}')"
        echo "- OS: $(if [ -f /etc/os-release ]; then grep PRETTY_NAME /etc/os-release | cut -d'"' -f2; elif [ -f /etc/redhat-release ]; then cat /etc/redhat-release; else uname -s; fi)"
        echo ""
    fi
    EOF

    chmod +x /etc/profile.d/welcome.sh
  EOT
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
  name       = "${local.prefix}ssh-key"
  public_key = resource.tls_private_key.tls_key.public_key_openssh
}


#############################################################################
# Provision VPC
#############################################################################

module "vpc" {
  source            = "terraform-ibm-modules/landing-zone-vpc/ibm"
  version           = "8.15.10"
  resource_group_id = module.resource_group.resource_group_id
  region            = var.region
  prefix            = local.prefix != "" ? trimspace(var.prefix) : null
  tags              = var.resource_tags
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
  version          = "1.4.2"
  architecture     = "amd64"
  operating_system = "ubuntu"
}

########################################################################################################################
# Virtual Server Instance
########################################################################################################################


module "vsi" {
  source                = "terraform-ibm-modules/landing-zone-vsi/ibm"
  version               = "6.2.7"
  resource_group_id     = module.resource_group.resource_group_id
  image_id              = module.vsi_image_selector.latest_image_id
  tags                  = var.resource_tags
  access_tags           = var.access_tags
  subnets               = module.vpc.subnet_zone_list
  vpc_id                = module.vpc.vpc_id
  prefix                = "${local.prefix}-vsi"
  machine_type          = "bx2d-2x8"
  user_data             = local.user_data
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
  source            = "../../"
  name              = "${local.prefix}adv-share"
  resource_group_id = module.resource_group.resource_group_id
  size              = 10
  iops              = 100
  zone              = "us-south-1"
  sg_mount_targets = [{
    security_group_ids = [module.vsi.vsi_security_group.id]
    subnet_id          = module.vpc.subnet_ids[0]
  }]
}

# cross-regional replica
resource "ibm_iam_authorization_policy" "cross_regional_replica_policy" {
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
    value    = module.file_storage.file_share.id
  }
}
resource "time_sleep" "wait_for_authorization_policy" {
  depends_on      = [ibm_iam_authorization_policy.cross_regional_replica_policy]
  create_duration = "30s"
}

module "cross_regional_replica" {
  providers = {
    ibm = ibm.replica
  }
  source     = "../../"
  profile    = module.file_storage.file_share.profile
  depends_on = [time_sleep.wait_for_authorization_policy]
  name       = "${local.prefix}replica"
  zone       = "us-east-1"
  create_share = {
    mode = "replica",
    replica = {
      source_share_crn = module.file_storage.file_share.crn # for cross-regional replica only source_share_crn must be passed
      cron_spec        = "0 */5 * * *"
  } }
}
