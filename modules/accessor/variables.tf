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
  description = "The unique name used to identify the file storage for vpc instance."
  type        = string
  default     = "share"
}

variable "source_crn" {
  description = "The Cloud Resource Name (CRN) of the source file share this source file share CRN is used to identify the cross account file share instance of which the binding needs to be created in the accessor account."
  type        = string
  default     = null
}
