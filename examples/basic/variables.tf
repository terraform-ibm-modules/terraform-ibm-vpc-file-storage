variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Key required for authentication and provisioning resources. This is sensitive information and should be kept secure."
  sensitive   = true
}
variable "region" {
  type        = string
  description = "The IBM Cloud region where all resources will be deployed. Example values: 'us-south', 'eu-gb', 'au-syd'."
  default     = "us-south"
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

variable "zone" {
  description = "Region where VPC will be created. To find your VPC region, use `ibmcloud is regions` command to find available regions."
  type        = string
  default     = "us-south-1"
}

variable "name" {
  description = "The unique name for this file storage for vpc instance."
  type        = string
  default     = "fs"
}

variable "replica" {
  description = "Optional replica share configuration. If null, no replica is created. Note: this can create replica only in anotheravailability zone of the same region as this File Storage instance"
  type = object({
    name      = string
    zone      = string
    cron_spec = string
  })
  default = {
    name      = "rep1"
    zone      = "us-south-2"
    cron_spec = "0 */5 * * *"
  }
}
