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
  description = "An existing resource group name to use for this example, if unset a new resource group will be created."
  default     = null
}

variable "resource_tags" {
  description = "List of resource tag to associate with all resource instances created by this example."
  type        = list(string)
  default     = null
}

variable "access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the VSI resources created by the example."
  default     = []
}

variable "prefix" {
  description = "The prefix that you would like to append to your resources."
  type        = string
  default     = "fs"
}

variable "existing_fileshare_crn" {
  description = "The existing CRN of a file storage instance"
  type        = string
  default     = null
}
