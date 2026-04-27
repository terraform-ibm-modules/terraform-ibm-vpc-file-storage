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
  description = "The unique name for this restored file storage instance."
  type        = string
  default     = "share"
}

variable "profile" {
  type        = string
  description = "Storage profile with which the file storage instance will be created. [learn more](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-profiles&interface=ui)"
  default     = "dp2"

  validation {
    condition     = var.profile == "dp2"
    error_message = "Only 'dp2' is supported by this module currently. Other profiles (for example 'rfs') are intentionally not supported yet due to limited availability refer [here](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-profiles&interface=ui)."
  }

}

variable "allowed_access_protocols" {
  description = "List of allowed access protocols for the file storage instance. Note: the only supported values are `nfs4`. [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_share#example-share-create-a-regional-file-share)"
  type        = list(string)
  default     = ["nfs4"]
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
    error_message = "initial_owner_uid must be >= 10000 (UID 0-10000 are reserved/used; UID 10000+ is available for user accounts)."
  }
}

variable "initial_owner_gid" {
  description = "Initial owner group ID (GID) applied to the root directory of the file share when mounted.[learn more](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-vpc-about#FS-supplemental-ids)."
  type        = number
  default     = 100
  validation {
    condition     = var.initial_owner_gid >= 100
    error_message = "initial_owner_gid must be >= 100 (GID 0-99 are reserved; GID 100+ is allocated for user groups)."
  }
}

variable "source_id" {
  description = "Source file share ID used to look up or create the snapshot by name."
  type        = string
  default     = null


  validation {
    condition = (
      (
        ((var.source_id != null && trimspace(var.source_id) != "") ? 1 : 0) +
        ((var.source_crn != null && trimspace(var.source_crn) != "") ? 1 : 0)
      ) == 1
    )
    error_message = "Exactly one of `source_id` or `source_crn` must be set ."
  }
}

variable "source_crn" {
  description = "Source file share CRN used to look up or create the snapshot by name."
  type        = string
  default     = null
}

variable "snapshot_restore" {
  description = "Snapshot restore settings to select the source snapshot by ID/CRN/name and optionally create the snapshot if the snapshot identified by snapshot_name does not exist before restoring."
  type = object({
    snapshot_id                = optional(string)
    snapshot_crn               = optional(string)
    snapshot_name              = optional(string)
    create_snapshot_if_missing = optional(bool, false)
  })
  default = null

  validation {
    condition = (
      var.snapshot_restore == null
      ? true
      : (
        (
          ((try(var.snapshot_restore.snapshot_id, null) != null &&
          trimspace(try(var.snapshot_restore.snapshot_id, "")) != "") ? 1 : 0) +
          ((try(var.snapshot_restore.snapshot_crn, null) != null &&
          trimspace(try(var.snapshot_restore.snapshot_crn, "")) != "") ? 1 : 0) +
          ((try(var.snapshot_restore.snapshot_name, null) != null &&
          trimspace(try(var.snapshot_restore.snapshot_name, "")) != "") ? 1 : 0)
        ) == 1
      )
    )
    error_message = "In snapshot_restore, set exactly one of snapshot_id, snapshot_crn, or snapshot_name."
  }

  validation {
    condition = (
      var.snapshot_restore == null ||
      !(try(var.snapshot_restore.snapshot_name, null) != null &&
      trimspace(try(var.snapshot_restore.snapshot_name, "")) != "") ||
      (
        (
          ((var.source_id != null && trimspace(var.source_id) != "") ? 1 : 0) +
          ((var.source_crn != null && trimspace(var.source_crn) != "") ? 1 : 0)
        ) == 1
      )
    )
    error_message = "When snapshot_restore.snapshot_name is set, you must also set exactly one of `source_id` or `source_crn` to identify the source file share."
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
    error_message = "kms_key_crn must be provided when kms_encryption_enabled is true."
  }
}
