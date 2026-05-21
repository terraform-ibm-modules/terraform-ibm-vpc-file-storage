terraform {
  required_version = ">= 1.9.0"

  required_providers {
    # Ensure that there is always 1 example locked into the lowest provider version of the range defined in the main module's version.tf
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 2.1.0, < 3.0.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.1, < 1.0.0"
    }
  }
}
