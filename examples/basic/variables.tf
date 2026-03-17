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
  description = "Base name for the file share"
  type        = string
  default     = "fs"
}

variable "replica_name" {
  description = "Replica share name"
  type        = string
  default     = "rep1"
}

variable "replica_zone" {
  description = "Replica zone"
  type        = string
  default     = "us-south-2"
}

variable "replica_cron_spec" {
  description = "Replica schedule cron spec"
  type        = string
  default     = "0 */5 * * *"
}
