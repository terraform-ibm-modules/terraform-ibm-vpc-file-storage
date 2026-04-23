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
  description = "List of resource tag to associate with all resource instances created by this example."
  type        = list(string)
  default     = null
}

variable "access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the VSI resources created by the example."
  default     = []
}

variable "replica_region" {
  description = "The region where your file storage instance replica will be created."
  type        = string
  default     = "us-east"
}

variable "kms_key_crn" {
  type        = string
  description = "Encryption key CRN for file share encryption."
  default     = null
}

variable "skip_iam_share_authorization_policy" {
  type        = bool
  default     = false
  description = "When using an existing KMS instance name, set this value to true if authorization is already enabled between KMS instance and the VPC file share. Otherwise, default is set to false. Ensuring proper authorization avoids access issues during deployment.For more information on how to create authorization policy manually, see [creating authorization policies for VPC file share](https://cloud.ibm.com/docs/vpc?topic=vpc-file-s2s-auth&interface=ui)."
}

variable "kms_encryption_enabled" {
  description = "Enable Key management , if set to `false` IBM-managed keys are used by default."
  type        = bool
  default     = false

  validation {
    condition     = !(var.kms_encryption_enabled && var.kms_key_crn == null)
    error_message = "`kms_key_crn` Must be provided when kms_encryption_enabled is true."
  }
}
