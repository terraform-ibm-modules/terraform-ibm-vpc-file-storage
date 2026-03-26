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
  description = "A list of access tags to apply to the Files Storage resources created by the module. For more information refer [here](https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial)"
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

variable "create_share" {
  description = <<-EOT
  Defines how the VPC file share is created. Exactly one mode must be selected:
  - standard: create a new empty share in a zone
  - snapshot_restore : create a share cloned from a snapshot
  - accessor: create an accessor share from an origin share
  - replica: create an replica share from an source share
  EOT

  type = object({
    mode = string # "standard" | "snapshot_restore" | "accessor" | "replica"


    # snapshot_restore mode
    source_snapshot = optional(object({
      crn = optional(string)
      id  = optional(string)
    }))

    # accessor mode
    origin_share = optional(object({
      crn = optional(string)
      id  = optional(string)
    }))

    # replica mode
    replica = optional(object({
      cron_spec        = string
      source_share_id  = optional(string)
      source_share_crn = optional(string)
    }))

  })

  default = {
    mode = "standard"
  }

  validation {
    condition     = contains(["standard", "snapshot_restore", "accessor", "replica"], var.create_share.mode)
    error_message = "create_share.mode must be one of: standard, snapshot_restore, accessor, replica."
  }

  validation {
    condition = (
      var.create_share.mode != "standard" ||
      (
        try(var.zone, null) != null &&
        try(var.create_share.source_snapshot, null) == null &&
        try(var.create_share.origin_share, null) == null
      )
    )
    error_message = "When mode=standard: zone is required and source_snapshot,origin_share must not be set."
  }

  validation {
    condition = (
      var.create_share.mode != "accessor" ||
      (
        try(var.create_share.origin_share, null) != null &&
        try(var.zone, null) == null &&
        try(var.create_share.source_snapshot, null) == null &&
        (
          (try(var.create_share.origin_share.crn, null) != null) !=
          (try(var.create_share.origin_share.id, null) != null)
        )

      )
    )
    error_message = "When mode=accessor: origin_share is required; set exactly one of origin_share.crn or origin_share.id; and zone,source_snapshot must not be set."
  }

  validation {
    condition = (
      var.create_share.mode != "snapshot_restore" ||
      (
        try(var.zone, null) == null &&
        try(var.create_share.origin_share, null) == null &&
        try(var.create_share.source_snapshot, null) != null &&
        (
          (try(var.create_share.source_snapshot.crn, null) != null) !=
          (try(var.create_share.source_snapshot.id, null) != null)
        )
      )
    )
    error_message = "When mode=snapshot_restore: source_snapshot is required; set exactly one of source_snapshot.crn or source_snapshot.id; and do not set zone,origin_share."
  }

  validation {
    condition = (
      var.create_share.mode != "replica" ||
      (

        try(var.zone, null) != null &&
        try(var.create_share.source_snapshot, null) == null &&
        try(var.create_share.origin_share, null) == null &&
        try(var.create_share.replica, null) != null &&
        try(trimspace(var.create_share.replica.cron_spec), "") != "" &&
        can(
          regex(
            "^([0-9*/,-]+\\s+){4}[0-9*/,-]+$",
            trimspace(var.create_share.replica.cron_spec)
          )
        ) &&
        (
          (try(var.create_share.replica.source_share_id, null) != null) !=
          (try(var.create_share.replica.source_share_crn, null) != null)
        )
      )
    )

    error_message = "When mode=replica: zone and create_share.replica are required; set cron_spec to a valid 5-field cron string; set exactly one of replica.source_share_id or replica.source_share_crn; and do not set source_snapshot or origin_share."
  }
}


variable "zone" {
  description = "Zone where the file share will be created, use `ibmcloud is zones` command in the target region to find zones available for each region."
  type        = string
  default     = null
}

variable "profile" {
  type        = string
  description = "Storage profile with which the file storage instance will be created "
  default     = "dp2"

  validation {
    condition     = var.profile == "dp2"
    error_message = "Only \"dp2\" is supported by this module currently. Other profiles (for example \"rfs\") are intentionally not supported yet due to limited availability refer [here](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-profiles&interface=ui)"
  }

}

variable "name" {
  description = "The unique name for this file storage for vpc instance."
  type        = string
  default     = "fs"
}

variable "size" {
  description = "File share size (capacity) in GB for this file storage for vpc instance. refer [here](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-profiles&interface=ui#file-storage-profile-overview) "
  type        = number
  default     = 10
  # Validation is done in the Terraform plan phase by the IBM provider, so no need to add extra validation here.
}

variable "iops" {
  description = "The maximum input/output operation performance bandwidth per second for the file share. refer [here](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-profiles&interface=ui#file-storage-profile-overview) "
  type        = number
  default     = 100
  # Validation is done in the Terraform plan phase by the IBM provider, so no need to add extra validation here.
}
variable "initial_owner_uid" {
  description = "Initial owner user ID (UID) applied to the root directory of the file share when mounted."
  type        = number
  default     = 10000
  validation {
    condition     = var.initial_owner_uid >= 10000
    error_message = "initial_owner_uid must be >= 10000 (UID 0-10000 are reserved/used; UID 10000+ is available for user accounts)."
  }
}

variable "initial_owner_gid" {
  description = "Initial owner group ID (GID) applied to the root directory of the file share when mounted."
  type        = number
  default     = 100
  validation {
    condition     = var.initial_owner_gid >= 100
    error_message = "initial_owner_gid must be >= 100 (GID 0-99 are reserved; GID 100+ is allocated for user groups)."
  }
}



variable "vpc_mount_targets" {
  type        = list(string)
  default     = []
  description = "List of VPC IDs to mount file share . If set the file storage is created with VPC access mode"
  validation {
    condition     = !(length(var.vpc_mount_targets) > 0 && length(var.sg_mount_targets) > 0)
    error_message = "Only one can be set: vpc_mount_targets or sg_mount_targets."
  }

  validation {
    condition = (
      contains(["standard", "accessor"], var.create_share.mode) ||
      length(var.vpc_mount_targets) == 0
    )
    error_message = "vpc_mount_targets can only be set when create_share.mode is \"standard\" or \"accessor\"."
  }
}

variable "sg_mount_targets" {
  description = "Security-group based mount targets. If set the file storage is created with Security Group access mode"
  type = list(object({
    vni_id = optional(string)

    # VNI prototype args (used when vni_id is not set)
    subnet_id                     = optional(string)
    security_group_ids            = optional(list(string), [])
    resource_group_id             = optional(string)
    protocol_state_filtering_mode = optional(string)

    # Reserved IP / Primary IP options
    primary_ip = optional(object({
      reserved_ip = optional(string)
      auto_delete = optional(bool, true)
      address     = optional(string)
      name        = optional(string)
    }))

    # Mount target settings
    transit_encryption = optional(string, "none")
    access_protocol    = optional(string, "nfs4")
  }))
  default = []

  validation {
    condition = (
      contains(["standard", "accessor"], var.create_share.mode) ||
      length(var.sg_mount_targets) == 0
    )
    error_message = "sg_mount_targets can only be set when create_share.mode is \"standard\" or \"accessor\"."
  }
  validation {
    condition = alltrue([
      for mt in var.sg_mount_targets :
      (
        try(mt.vni_id, null) == null
        ||
        (
          try(mt.subnet_id, null) == null &&
          length(try(mt.security_group_ids, [])) == 0 &&
          try(mt.resource_group_id, null) == null &&
          try(mt.protocol_state_filtering_mode, null) == null &&
          try(mt.primary_ip, null) == null
        )
      )
    ])
    error_message = "Within sg_mount_targets if vni_id is set, other VNI prototype fields (subnet_id, security_group_ids, resource_group_id, protocol_state_filtering_mode, primary_ip) must not be set."
  }
  validation {
    condition = alltrue([
      for mt in var.sg_mount_targets :
      (
        try(mt.primary_ip, null) == null
        ||
        (
          try(mt.primary_ip.reserved_ip, null) == null
          ||
          (
            try(mt.primary_ip.address, null) == null &&
            try(mt.primary_ip.name, null) == null
          )
        )
      )
    ])
    error_message = "Within sg_mount_targets if primary_ip, reserved_ip is mutually exclusive with address and name (and auto_delete if you choose to enforce strictly)."
  }
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
  description = "Enable Key management , if set to `false` IBM-managed keys are used by default"
  type        = bool
  default     = false
  validation {
    condition     = !(var.kms_encryption_enabled && var.encryption_key_crn == null)
    error_message = "encryption_key_crn must be provided when kms_encryption_enabled is true."
  }
}
