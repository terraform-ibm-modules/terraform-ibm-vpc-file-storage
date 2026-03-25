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
  - snapshot: create a share cloned from a snapshot
  - accessor: create an accessor share from an origin share CRN
  EOT

  type = object({
    mode = string # "standard" | "snapshot" | "accessor"


    # snapshot mode
    source_snapshot = optional(object({
      crn = optional(string)
      id  = optional(string)
    }))

    # accessor mode
    origin_share = optional(object({
      crn = optional(string)
      id  = optional(string)
    }))

  })

  default = {
    mode = "standard"
  }

  validation {
    condition     = contains(["standard", "snapshot", "accessor"], var.create_share.mode)
    error_message = "create_share.mode must be one of: standard, snapshot, accessor."
  }

  validation {
    condition = (
      var.create_share.mode != "standard" ||
      (
        try(var.zone, null) != null &&
        try(var.create_share.source_snapshot, null) == null &&
        try(var.create_share.origin_share_crn, null) == null
      )
    )
    error_message = "When mode=standard: zone is required and source_snapshot,origin_share_crn must not be set."
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
      var.create_share.mode != "snapshot" ||
      (
        try(var.zone, null) == null &&
        try(var.create_share.origin_share_crn, null) == null &&
        try(var.create_share.source_snapshot, null) != null &&
        (
          (try(var.create_share.source_snapshot.crn, null) != null) !=
          (try(var.create_share.source_snapshot.id, null) != null)
        )
      )
    )
    error_message = "When mode=snapshot: source_snapshot is required; set exactly one of source_snapshot.crn or source_snapshot.id; and do not set zone,origin_share_crn."
  }
}


variable "zone" {
  description = "Zone where the file share will be created, use `ibmcloud is zones` command in the target region to find zones available for each region."
  type        = string
  default     = null
}

variable "profile" {
  type        = string
  description = "Storage profile with wich the file storage instance will be created "
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
  description = "UID for the root of the file share."
  type        = number
  default     = 10000
  validation {
    condition     = var.initial_owner_uid >= 10000
    error_message = "initial_owner_uid must be >= 10000 to avoid reserved UID ranges."
  }
}

variable "initial_owner_gid" {
  description = "GID for the root of the file share."
  type        = number
  default     = 10000
  validation {
    condition     = var.initial_owner_gid >= 10000
    error_message = "initial_owner_gid must be >= 10000 to avoid reserved GID ranges."
  }
}

variable "replica" {
  description = "Replica share configuration. If null, no replica is created. Note: this can create replica only in another availability zone of the same region as this File Storage instance"
  type = object({
    name      = string
    zone      = string
    cron_spec = string
  })
  default = null

  validation {
    condition = var.replica == null || (
      length(var.replica.name) > 0 &&
      length(var.replica.zone) > 0 &&
      length(var.replica.cron_spec) > 0
    )
    error_message = "When replica is set, name, zone, and cron_spec must all be non-empty."
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
    condition     = var.create_share.mode == "standard" || length(var.vpc_mount_targets) == 0
    error_message = "vpc_mount_targets can only be set when create_share.mode is \"standard\"."
  }
}

variable "sg_mount_targets" {
  description = "Security-group based mount targets . If set the file storage is created with Security Group access mode"
  type = list(object({
    # Optional: use an existing VNI
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
