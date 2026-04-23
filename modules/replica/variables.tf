##############################################################################
# Account Variables
##############################################################################

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
  description = "Zone where the file share replica will be created, To find zones available for each region refer [here](https://cloud.ibm.com/docs/vpc?topic=vpc-vpc-reference&interface=cli#zones-list)."
  type        = string
  default     = null
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

variable "iops" {
  description = "The maximum input/output operation performance bandwidth per second for the file share. refer [here](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-profiles&interface=ui#file-storage-profile-overview)."
  type        = number
  default     = 100
  # Validation is done in the Terraform plan phase by the IBM provider, so no need to add extra validation here.
}

variable "cross_regional_replica" {
  type        = bool
  description = "Set true, if provisioning the replica file share in a zone that is in a different region than the source file share. Note : source file share and its cross-regional replica must be in the same account."
  default     = false
}

variable "cron_spec" {
  description = "The cron specification expression for the file share replication schedule."
  type        = string
  default     = "0 */5 * * *"

  validation {
    condition = can(
      regex(
        "^([0-9*/,-]+\\s+){4}[0-9*/,-]+$",
        trimspace(var.cron_spec)
      )
    )
    error_message = "set cron_spec to a valid 5-field cron string"
  }
}

variable "source_id" {
  description = "The ID of the source file share for this replica file share. The specified file share must not already have a replica, and must not be a replica."
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

  validation {
    condition = (
      var.cross_regional_replica == false ||
      (
        (var.source_id == null || trimspace(var.source_id) == "") &&
        (var.source_crn != null && trimspace(var.source_crn) != "")
      )
    )
    error_message = "When cross_regional_replica is true, you must set source_crn and must not set source_id."
  }
}

variable "source_crn" {
  description = "The CRN of the source file share. The specified file share must not already have a replica, and must not be a replica. Note for cross regional replica only CRN should be set [Learn more](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-create-replication&interface=terraform)"
  type        = string
  default     = null
}

variable "kms_key_crn" {
  type        = string
  default     = null
  description = "Encryption key CRN for the replica file share , required if creating a cross regional replica of a source file share that has customer-managed encryption. [Learn more](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-create-replication&interface=terraform)."

  validation {
    condition = (
      var.kms_key_crn == null ||
      trim(var.kms_key_crn) == "" ||
      var.cross_regional_replica == true
    )
    error_message = "If `kms_key_crn` is set , `cross_regional_replica` must be true; "
  }
}
