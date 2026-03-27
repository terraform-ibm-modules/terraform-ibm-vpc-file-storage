########################################################################################################################
# Input variables
########################################################################################################################

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
  description = "An existing resource group name to use for this example, if unset a new resource group will be created."
  default     = null
}
variable "prefix" {
  description = "The prefix that you would like to append to your resources."
  type        = string
  default     = "fs"
}

variable "resource_tags" {
  description = "List of tags for the resource created."
  type        = list(string)
  default     = null
}

variable "access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the VSI resources created by the module."
  default     = []
}
variable "replica_region" {
  description = "The region where your file storage instance replica will be created."
  type        = string
  default     = "us-east"
}
