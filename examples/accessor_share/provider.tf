provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
}

provider "ibm" {
  alias            = "accessor"
  ibmcloud_api_key = var.ibmcloud_accessor_api_key
  region           = var.region
}
