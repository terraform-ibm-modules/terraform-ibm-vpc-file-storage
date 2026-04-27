##############################################################################
# Account Variables
##############################################################################

variable "resource_group_id" {
  description = "ID of resource group to provision file storage."
  type        = string
  default     = null
}

variable "tags" {
  description = "List of tags to apply to resources created by this module."
  type        = list(string)
  default     = []
}

variable "access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the Files Storage resources created by the module. For more information refer [here](https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial)."
  default     = []

  validation {
    condition = alltrue([
      for tag in var.access_tags : can(regex("[\\w\\-_\\.]+:[\\w\\-_\\.]+", tag)) && length(tag) <= 128
    ])
    error_message = "Tags must match the regular expression \"[\\w\\-_\\.]+:[\\w\\-_\\.]+\". For more information refer [here](https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#limits)."
  }
}

##############################################################################
# File Share Variables
##############################################################################

variable "name" {
  description = "The unique name for this file storage for vpc instance."
  type        = string
  default     = "share"
}

variable "zone" {
  description = "Zone where the file share will be created, To find zones available for each region refer [here](https://cloud.ibm.com/docs/vpc?topic=vpc-vpc-reference&interface=cli#zones-list)."
  type        = string
  default     = null
}

variable "allowed_access_protocols" {
  description = "List of allowed access protocols for the file storage instance. Note: the only supported values are `nfs4`. [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_share#example-share-create-a-regional-file-share)"
  type        = list(string)
  default     = ["nfs4"]
}

variable "access_control_mode" {
  description = "Controls how the mount target authorizes access to the file share (security_group for Security Group based access, or vpc for same-zone VPC access).[Learn more](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-vpc-about#fs-mount-access-mode)."
  type        = string
  default     = null
}

variable "profile" {
  type        = string
  description = "Storage profile with which the file storage instance will be created. [learn more](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-profiles&interface=ui)."
  default     = "dp2"

  validation {
    condition     = var.profile == "dp2"
    error_message = "Only 'dp2' is supported by this module currently. Other profiles (for example 'rfs') are intentionally not supported yet due to limited availability refer [here](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-profiles&interface=ui)."
  }

}

variable "size" {
  description = "File share size (capacity) in GB for this file storage for vpc instance. refer [here](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-profiles&interface=ui#file-storage-profile-overview)."
  type        = number
  default     = 10
  # Validation is done in the Terraform plan phase by the IBM provider, so no need to add extra validation here.
}

variable "iops" {
  description = "The maximum input/output operation performance bandwidth per second for the file share. refer [here](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-profiles&interface=ui#file-storage-profile-overview)."
  type        = number
  default     = 100
  # Validation is done in the Terraform plan phase by the IBM provider, so no need to add extra validation here.
}

variable "initial_owner_uid" {
  description = "Initial owner user ID (UID) applied to the root directory of the file share when mounted. [learn more](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-vpc-about#FS-supplemental-ids)."
  type        = number
  default     = 10000
  validation {
    condition     = var.initial_owner_uid >= 10000
    error_message = "`initial_owner_uid` Must be >= 10000 (UID 0-10000 are reserved/used; UID 10000+ is available for user accounts)."
  }
}

variable "initial_owner_gid" {
  description = "Initial owner group ID (GID) applied to the root directory of the file share when mounted.[learn more](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-vpc-about#FS-supplemental-ids)."
  type        = number
  default     = 100
  validation {
    condition     = var.initial_owner_gid >= 100
    error_message = "`initial_owner_gid` Must be >= 100 (GID 0-99 are reserved; GID 100+ is allocated for user groups)."
  }
}

##############################################################################
# KMS Variables
##############################################################################

variable "kms_key_crn" {
  type        = string
  description = "The CRN of the key management service key to encrypt the data in the File Storage instance."
  default     = null
}

variable "skip_iam_share_authorization_policy" {
  type        = bool
  default     = false
  description = "When using an existing KMS instance name, set this value to true if authorization is already enabled between KMS instance and the VPC file share. Otherwise, default is set to false. Ensuring proper authorization avoids access issues during deployment.For more information on how to create authorization policy manually, see [creating authorization policies for VPC file share](https://cloud.ibm.com/docs/vpc?topic=vpc-file-s2s-auth&interface=ui)."
}

variable "kms_encryption_enabled" {
  description = "Whether to use key management service key encryption to encrypt data in File storage instance  , if set to `false` IBM-managed keys are used by default."
  type        = bool
  default     = false
  validation {
    condition     = !(var.kms_encryption_enabled && var.kms_key_crn == null)
    error_message = "`kms_key_crn` Must be provided when kms_encryption_enabled is true."
  }
}
