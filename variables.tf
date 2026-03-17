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
  description = "A list of access tags to apply to the Filse Storage resources created by the module. For more information, see https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial."
  default     = []

  validation {
    condition = alltrue([
      for tag in var.access_tags : can(regex("[\\w\\-_\\.]+:[\\w\\-_\\.]+", tag)) && length(tag) <= 128
    ])
    error_message = "Tags must match the regular expression \"[\\w\\-_\\.]+:[\\w\\-_\\.]+\". For more information, see https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#limits."
  }
}
##############################################################################
# File Share Variables
##############################################################################
variable "zone" {
  description = "Region where VPC will be created. To find your VPC region, use `ibmcloud is regions` command to find available regions."
  type        = string
  default     = null
}

variable "profile" {
  type        = string
  description = "File storage profiles"
  default     = "dp2"

  validation {
    condition     = var.profile == "dp2"
    error_message = "Currently only \"dp2\" profile is supported by this module"
  }

}

variable "name" {
  description = "Base name for the file share"
  type        = string
  default     = null

  validation {
    condition     = var.name != null && length(trimspace(var.name)) > 0
    error_message = "name must be set."
  }
}

variable "size" {
  description = "Size in GB. The size of the file share"
  type        = number
  default     = null
  # validation happens in plan phase by the provider
}

variable "iops" {
  description = "The maximum input/output operation performance bandwidth per second for the file share."
  type        = number
  default     = null
  # validation happens in plan phase by the provider
}
variable "initial_owner_uid" {
  description = "UID for the root of the file share. Use >= 10000 to avoid reserved ranges."
  type        = number
  default     = 10000
}

variable "initial_owner_gid" {
  description = "GID for the root of the file share. Use >= 100 (preferably >= 10000) to avoid reserved ranges."
  type        = number
  default     = 10000
}
variable "source_snapshot_crn" {
  description = "If set, create the share by restoring from this snapshot CRN."
  type        = string
  default     = null
  validation {
    condition     = !(var.enable_snapshot_restore && var.source_snapshot_crn == null)
    error_message = "source_snapshot_crn must be provided when enable_snapshot_restore is true."
  }
}

variable "enable_snapshot_restore" {
  description = "Set to true if restoring from a snapshot"
  type        = bool
  default     = false
  validation {
    condition = !(
      var.enable_snapshot_restore == true && var.origin_share_crn != null
    )
    error_message = "If enable_snapshot_restore is true, origin_share_crn must not be set."
  }
}

variable "replica_name" {
  description = "Replica share name"
  type        = string
  default     = null
}

variable "replica_zone" {
  description = "Replica zone"
  type        = string
  default     = null
}

variable "replica_cron_spec" {
  description = "Replica schedule cron spec "
  type        = string
  default     = null
}

variable "vpc_mount_targets" {
  description = "List of VPC IDs to mount file share . If set the file storage is created with VPC access mode"
  type        = list(string)
  default     = []
  validation {
    condition     = !(length(var.vpc_mount_targets) > 0 && length(var.sg_mount_targets) > 0)
    error_message = "Only one can be set either vpc_ids or sg_mount_targets, not both."
  }
}

variable "sg_mount_targets" {
  description = "Security-group based mount targets . If set the file storage is created with Security Group access mode"
  type = list(object({
    subnet_id          = string
    security_group_ids = list(string)
    transit_encryption = optional(string, "none")
  }))
  default = []
}

variable "origin_share_crn" {
  type        = string
  description = "CRN of origin file share. Required when creating cross account accessor Share"
  default     = null
}

##############################################################################
# KMS Variables
##############################################################################

variable "encryption_key_crn" {
  type        = string
  description = "Encryption key CRN for file share encryption"
  default     = null
}

variable "skip_iam_share_authorization_policy" {
  type        = bool
  default     = false
  description = "When using an existing KMS instance name, set this value to true if authorization is already enabled between KMS instance and the VPC file share. Otherwise, default is set to false. Ensuring proper authorization avoids access issues during deployment.For more information on how to create authorization policy manually, see [creating authorization policies for VPC file share](https://cloud.ibm.com/docs/vpc?topic=vpc-file-s2s-auth&interface=ui)."
}

variable "kms_encryption_enabled" {
  description = "Enable Key management"
  type        = bool
  default     = false
}
