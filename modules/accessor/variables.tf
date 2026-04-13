##############################################################################
# Account Variables
##############################################################################

# variable "resource_group_id" {
#   description = "ID of resource group to provision file storage."
#   type        = string
#   default     = null
# }

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
