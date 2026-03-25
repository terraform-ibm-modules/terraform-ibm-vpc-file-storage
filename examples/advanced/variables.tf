########################################################################################################################
# Input variables
########################################################################################################################

#
# Module developer tips:
#   - Examples are references that consumers can use to see how the module can be consumed. They are not designed to be
#     flexible re-usable solutions for general consumption, so do not expose any more variables here and instead hard
#     code things in the example main.tf with code comments explaining the different configurations.
#   - For the same reason as above, do not add default values to the example inputs.
#

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Key."
  sensitive   = true
}

variable "region" {
  type        = string
  description = "Region to provision all resources created by this example."
}
variable "resource_group" {
  type        = string
  description = "An existing resource group name to use for this example, if unset a new resource group will be created"
  default     = null
}
variable "prefix" {
  description = "The prefix that you would like to append to your resources"
  type        = string
  default     = "fs"
}

variable "resource_tags" {
  description = "List of Tags for the resource created"
  type        = list(string)
  default     = null
}

variable "access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the VSI resources created by the module."
  default     = []
}

variable "user_data" {
  description = "The user data that automatically performs common configuration tasks or runs scripts. When using the user_data variable in your configuration, it's essential to provide the content in the correct format for it to be properly recognized by the terraform. Use <<-EOT and EOT to enclose your user_data content to ensure it's passed as multi-line string. [Learn more](https://cloud.ibm.com/docs/secure-infrastructure-vpc?topic=secure-infrastructure-vpc-user-data)"
  type        = string
  default     = <<-EOT
#!/bin/bash

cat > /etc/profile.d/welcome.sh << 'EOF'
#!/bin/bash
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
}

variable "name" {
  description = "The unique name for this file storage for vpc instance."
  type        = string
  default     = "fs"
}

variable "zone" {
  description = "Zone where the file share will be created, use `ibmcloud is zones` command in the target region to find zones available for each region."
  type        = string
  default     = "us-south-1"
}

variable "replica_name" {
  description = "Replica share name"
  type        = string
  default     = "rep1"
}

variable "replica_zone" {
  description = "Replica zone for cross-regional replica"
  type        = string
  default     = "us-east-1"
}

variable "replica_region" {
  description = "Replica region for cross-regional replica"
  type        = string
  default     = "us-east"
}

variable "replica_cron_spec" {
  description = "Replica schedule cron spec"
  type        = string
  default     = "0 */5 * * *"
}
