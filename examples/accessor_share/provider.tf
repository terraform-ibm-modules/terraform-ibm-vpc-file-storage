provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
}

# Below provider configuration is required to initialize and access accessor account , which will create a binding with the file share instance in your origin account , refer : https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-accessor-create&interface=terraform
provider "ibm" {
  alias            = "accessor"
  ibmcloud_api_key = var.ibmcloud_accessor_api_key
  region           = var.region
}
