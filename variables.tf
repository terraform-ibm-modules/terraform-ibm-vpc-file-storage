##############################################################################
# Account Variables
##############################################################################

variable "resource_group_id" {
  description = "ID of resource group to provision file storage."
  type        = string
  default     = null

  validation {
    condition = (
      contains(["standard", "snapshot_restore"], var.mode)
      ? true
      : (var.resource_group_id == null || trimspace(var.resource_group_id) == "")
    )
    error_message = "resource_group_id Can be set only when mode is 'standard' or 'snapshot_restore'."
  }
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
    error_message = "Tags must match the regular expression '[\\w\\-_\\.]+:[\\w\\-_\\.]+'. For more information refer [here](https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#limits)."
  }
}

##############################################################################
# File Share Variables
##############################################################################
variable "mode" {
  description = <<-EOT
    Determines which type of file share to create:
      - standard         : create a new empty file share in a zone
      - snapshot_restore : create a file share cloned from a snapshot
      - accessor         : create a cross-account accessor share binding of an existing file share
      - replica          : create a replica share of an existing file share
  EOT
  type        = string
  default     = "standard"
  validation {
    condition     = contains(["standard", "snapshot_restore", "accessor", "replica"], var.mode)
    error_message = "Mode` must be one of: standard, snapshot_restore, accessor, replica."
  }
}

variable "id" {
  description = "The ID of the source file share (required for non-standard modes; set exactly one of id or crn)."
  type        = string
  default     = null

  validation {
    condition = (
      var.mode == "standard"
      ? (
        (var.id == null || trimspace(var.id) == "") &&
        (var.crn == null || trimspace(var.crn) == "")
      )
      : (
        (
          ((var.id != null && trimspace(var.id) != "") ? 1 : 0) +
          ((var.crn != null && trimspace(var.crn) != "") ? 1 : 0)
        ) == 1
      )
    )
    error_message = "When mode is `standard`, id/crn must be null/empty; otherwise exactly one of `id` or `crn` must be set ."
  }
}

variable "crn" {
  description = "The CRN of the source file share (required for non-standard modes; set exactly one of id or crn)."
  type        = string
  default     = null
}

variable "name" {
  description = "The unique name for this file storage for vpc instance."
  type        = string
  default     = "share"
}

variable "zone" {
  description = "Zone where the file share will be created. To find zones available for each region refer [here](https://cloud.ibm.com/docs/vpc?topic=vpc-vpc-reference&interface=cli#zones-list)."
  type        = string
  default     = null

  validation {
    condition = (
      contains(["standard", "replica"], var.mode)
      ? true
      : (var.zone == null || trimspace(var.zone) == "")
    )
    error_message = "Zone can be set only when mode is 'standard' or 'replica' ."
  }
}

variable "profile" {
  type        = string
  description = "Storage profile with which the file storage instance will be created. [know more](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-profiles&interface=ui)"
  default     = "dp2"

  validation {
    condition     = var.profile == "dp2"
    error_message = "Only 'dp2' is supported by this module currently. Other profiles (for example 'rfs') are intentionally not supported yet due to limited availability refer [here](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-profiles&interface=ui)."
  }
}

variable "allowed_access_protocols" {
  description = "List of allowed access protocols for the file storage instance. Note: the only supported values are `nfs4`. [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_share#example-share-create-a-regional-file-share)"
  type        = list(string)
  default     = []

  validation {
    condition = (
      contains(["standard", "snapshot_restore"], var.mode)
      ? true
      : length(var.allowed_access_protocols) == 0
    )
    error_message = "allowed_access_protocols Can be set only when mode is `standard` or `snapshot_restore`. For other modes, set it to an empty list ([])."
  }
}

variable "size" {
  description = "File share size (capacity) in GB for this file storage for vpc instance. refer [here](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-profiles&interface=ui#file-storage-profile-overview)."
  type        = number
  default     = null
  # Value validation is done in the Terraform plan phase by the IBM provider, so no need to add extra validation here.

  validation {
    condition = (
      contains(["standard", "snapshot_restore"], var.mode)
      ? var.size != null
      : var.size == null
    )
    error_message = "Size must be set only when mode is 'standard' or 'snapshot_restore'."
  }

}

variable "iops" {
  description = "The maximum input/output operation performance bandwidth per second for the file share. refer [here](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-profiles&interface=ui#file-storage-profile-overview)."
  type        = number
  default     = null
  # Value validation is done in the Terraform plan phase by the IBM provider, so no need to add extra validation here.

  validation {
    condition     = var.mode != "accessor" || var.iops == null
    error_message = "Iops must not be set when mode is 'accessor'."
  }

}

variable "initial_owner_uid" {
  description = "Initial owner user ID (UID) applied to the root directory of the file share when mounted. [know more](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-vpc-about#FS-supplemental-ids)."
  type        = number
  default     = null

  validation {
    condition = (
      contains(["standard", "snapshot_restore"], var.mode)
      ? var.initial_owner_uid != null
      : var.initial_owner_uid == null
    )
    error_message = "`initial_owner_uid` Must be set only when mode is 'standard' or 'snapshot_restore'."
  }
  validation {
    condition     = var.initial_owner_uid == null || var.initial_owner_uid >= 10000
    error_message = "`initial_owner_uid` Must be >= 10000 (UID 0-10000 are reserved/used; UID 10000+ is available for user accounts)."
  }
}

variable "initial_owner_gid" {
  description = "Initial owner group ID (GID) applied to the root directory of the file share when mounted.[know more](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-vpc-about#FS-supplemental-ids)."
  type        = number
  default     = null
  validation {
    condition = (
      contains(["standard", "snapshot_restore"], var.mode)
      ? var.initial_owner_gid != null
      : var.initial_owner_gid == null
    )
    error_message = "`initial_owner_gid` Must be set only when mode is 'standard' or 'snapshot_restore'."
  }
  validation {
    condition     = var.initial_owner_gid == null || var.initial_owner_gid >= 100
    error_message = "`initial_owner_gid` Must be >= 100 (GID 0-99 are reserved; GID 100+ is allocated for user groups)."
  }
}

variable "vpc_mount_targets" {
  description = "Map of VPC mount targets for the file share . If a value is provided for this the file storage is created with 'vpc' access_control_mode .[know more](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-vpc-about#fs-mount-access-mode)."
  type = map(object({
    vpc_id = string
    name   = string
  }))
  default = {}
  validation {
    condition     = !(length(var.vpc_mount_targets) > 0 && length(var.sg_mount_targets) > 0)
    error_message = "Only one can be set: vpc_mount_targets or sg_mount_targets."
  }
  validation {
    condition = length(distinct([
      for _, mt in var.vpc_mount_targets : mt.name
    ])) == length(var.vpc_mount_targets)
    error_message = "Within vpc_mount_targets, 'name' must be unique for each entry."
  }
}

variable "sg_mount_targets" {
  description = "Map of Security-group based mount targets for the file share. If a value is provided for this the file storage is created with 'security_group' access_control_mode .[know more](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-vpc-about#fs-mount-access-mode)."
  type = map(object({
    name   = string
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
  default = {}

  validation {
    condition = length(distinct([
      for _, mt in var.sg_mount_targets : mt.name
    ])) == length(var.sg_mount_targets)
    error_message = "Within sg_mount_targets, 'name' must be unique for each entry."
  }

  validation {
    condition = alltrue([
      for _, mt in var.sg_mount_targets :
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
      for _, mt in var.sg_mount_targets :
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
    error_message = "Within sg_mount_targets in primary_ip, reserved_ip is mutually exclusive with address and name (and auto_delete if you choose to enforce strictly)."
  }
}

##############################################################################
# Replica Share Variables
##############################################################################
variable "cron_spec" {
  description = "The cron specification expression for the file share replication schedule. Required when creating a replica share"
  type        = string
  default     = null

  validation {
    condition = (
      var.mode == "replica"
      ? (var.cron_spec != null && trimspace(var.cron_spec) != "")
      : (var.cron_spec == null || trimspace(var.cron_spec) == "")
    )
    error_message = "`cron_spec` Must be set (non-empty) only when mode is `replica`; otherwise it must be null/empty."
  }
}

variable "cross_regional_replica" {
  type        = bool
  description = "Set true, if provisioning the replica file share in a zone that is in a different region than the source file share. Note : source file share and its cross-regional replica must be in the same account."
  default     = false

  validation {
    condition     = var.mode == "replica" || var.cross_regional_replica == false
    error_message = "`cross_regional_replica` Can be true only when mode is `replica`."
  }
}
##############################################################################
# Snapshot Restore Variable
##############################################################################


variable "snapshot_restore" {
  description = "Snapshot restore settings to select the source snapshot by ID/CRN/name and optionally create the snapshot if the snapshot identified by snapshot_name does not exist before restoring. (used only when mode is 'snapshot_restore')."
  type = object({
    snapshot_id                = optional(string)
    snapshot_crn               = optional(string)
    snapshot_name              = optional(string)
    create_snapshot_if_missing = optional(bool, false)
  })
  default = null

  validation {
    condition     = (var.mode == "snapshot_restore") == (var.snapshot_restore != null)
    error_message = "`snapshot_restore` Must be set if and only if mode is 'snapshot_restore'."
  }

}

##############################################################################
# KMS Variables
##############################################################################

variable "kms_key_crn" {
  type        = string
  description = "The CRN of the key management service key to encrypt the data in the File Storage instance."
  default     = null

  validation {
    condition = (
      var.mode != "accessor"
      || var.kms_key_crn == null
      || trimspace(var.kms_key_crn) == ""
    )
    error_message = "`kms_key_crn` Must be null/empty when mode is 'accessor'."
  }

  validation {
    condition = (
      var.mode != "replica"
      || var.cross_regional_replica
      || var.kms_key_crn == null
      || trimspace(var.kms_key_crn) == ""
    )
    error_message = "When mode is 'replica' and cross_regional_replica is false, kms_key_crn must be null/empty. When cross_regional_replica is true, kms_key_crn is optional."
  }
}

variable "skip_iam_share_authorization_policy" {
  type        = bool
  default     = false
  description = "When using an existing KMS instance name, set this value to true if authorization is already enabled between KMS instance and the VPC file share. Otherwise, default is set to false. Ensuring proper authorization avoids access issues during deployment.For more information on how to create authorization policy manually, see [creating authorization policies for VPC file share](https://cloud.ibm.com/docs/vpc?topic=vpc-file-s2s-auth&interface=ui)."

  validation {
    condition = (
      contains(["replica", "accessor"], var.mode)
      ? var.skip_iam_share_authorization_policy == false
      : true
    )
    error_message = "`skip_iam_share_authorization_policy` Must be false when mode is 'replica' or 'accessor'."
  }
}

variable "kms_encryption_enabled" {
  description = "Whether to use key management service key encryption to encrypt data in File storage instance  , if set to `false` IBM-managed keys are used by default."
  type        = bool
  default     = false

  validation {
    condition     = !(var.kms_encryption_enabled && var.kms_key_crn == null)
    error_message = "`kms_key_crn` Must be provided when kms_encryption_enabled is true."
  }


  validation {
    condition = (
      contains(["replica", "accessor"], var.mode)
      ? var.kms_encryption_enabled == false
      : true
    )
    error_message = "`kms_encryption_enabled` Must be false when mode is 'replica' or 'accessor'."
  }
}
