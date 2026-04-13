# File Storage for VPC replica module

You can use this submodule to provision and configure [read-only replicas](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-vpc-about#fs-repl-failover-overview) of an existing file storage instance.

Using this module you can create the following replicas :

- Zonal replica (same region as the file storage instance but different availability zone)
- Cross-regional replica (different region and availability zone from the file storage instance)



### Usage
```hcl

module "replica" {
  source            = "terraform-ibm-modules/vpc-file-storage/ibm"
  version           = "X.Y.Z" # Replace "X.Y.Z" with a release version to lock into a specific release
  mode      = "replica"
  name      = "zonal-replica"
  zone      = "us-south-2"
  id        = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"  # Replace with the actual ID of the file storage instance to create replica for
  cron_spec         = "0 */5 * * *"
}

module "cross_regional_replica" {
  source            = "terraform-ibm-modules/vpc-file-storage/ibm"
  version           = "X.Y.Z" # Replace "X.Y.Z" with a release version to lock into a specific release
  mode      = "replica"
  name      = "cross-regional-replica"
  zone      = "us-east-2"
  crn        = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"  # Replace with the actual CRN of the file storage instance to create replica for
  cron_spec         = "0 */5 * * *"
  cross_regional_replica = true
}
```

## Required IAM access policies
You need the following permissions to run this module.

- Account Management
    - **Resource Group** service
        - `Viewer` platform access
- IAM Services
    - **VPC Infrastructure Services** service
        - `Administrator` platform access


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.88.0, < 2.0.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.1, < 1.0.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_share_crn_parser"></a> [share\_crn\_parser](#module\_share\_crn\_parser) | terraform-ibm-modules/common-utilities/ibm//modules/crn-parser | 1.4.1 |

### Resources

| Name | Type |
|------|------|
| [ibm_iam_authorization_policy.cross_regional_replica_policy](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_is_share.replica](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_share) | resource |
| [time_sleep.wait_for_authorization_policy](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [ibm_iam_account_settings.origin](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/iam_account_settings) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_tags"></a> [access\_tags](#input\_access\_tags) | A list of access tags to apply to the Files Storage resources created by the module. For more information refer [here](https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial). | `list(string)` | `[]` | no |
| <a name="input_cron_spec"></a> [cron\_spec](#input\_cron\_spec) | The cron specification expression for the file share replication schedule. | `string` | `null` | no |
| <a name="input_cross_regional_replica"></a> [cross\_regional\_replica](#input\_cross\_regional\_replica) | Set true, if provisioning the replica file share in a zone that is in a different region than the source file share. Note : source file share and its cross-regional replica must be in the same account. | `bool` | `false` | no |
| <a name="input_encryption_key_crn"></a> [encryption\_key\_crn](#input\_encryption\_key\_crn) | Encryption key CRN for the replica file share , required if creating a cross regional replica of a source file share that has customer-managed encryption. [Learn more](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-create-replication&interface=terraform). | `string` | `null` | no |
| <a name="input_iops"></a> [iops](#input\_iops) | The maximum input/output operation performance bandwidth per second for the file share. refer [here](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-profiles&interface=ui#file-storage-profile-overview). | `number` | `100` | no |
| <a name="input_name"></a> [name](#input\_name) | The unique name for this file storage for vpc instance. | `string` | `"share"` | no |
| <a name="input_profile"></a> [profile](#input\_profile) | Storage profile with which the file storage instance will be created. [learn more](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-profiles&interface=ui) | `string` | `"dp2"` | no |
| <a name="input_source_crn"></a> [source\_crn](#input\_source\_crn) | The CRN of the source file share. The specified file share must not already have a replica, and must not be a replica. Note for cross regional replica only CRN should be set [Learn more](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-create-replication&interface=terraform) | `string` | `null` | no |
| <a name="input_source_id"></a> [source\_id](#input\_source\_id) | The ID of the source file share for this replica file share. The specified file share must not already have a replica, and must not be a replica. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | List of tags to apply to resources created by this module. | `list(string)` | `[]` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | Zone where the file share replica will be created, To find zones available for each region refer [here](https://cloud.ibm.com/docs/vpc?topic=vpc-vpc-reference&interface=cli#zones-list). | `string` | `null` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_control_mode"></a> [access\_control\_mode](#output\_access\_control\_mode) | The access control mode for the replica file share |
| <a name="output_access_tags"></a> [access\_tags](#output\_access\_tags) | Access management tags associated with the replica file share |
| <a name="output_allowed_transit_encryption_modes"></a> [allowed\_transit\_encryption\_modes](#output\_allowed\_transit\_encryption\_modes) | The transit encryption modes allowed for this file share. |
| <a name="output_created_at"></a> [created\_at](#output\_created\_at) | The RFC3339 timestamp when the replica file share was created. |
| <a name="output_crn"></a> [crn](#output\_crn) | The Cloud Resource Name (CRN) of the replica file share |
| <a name="output_encryption"></a> [encryption](#output\_encryption) | The type of encryption used for this file share. |
| <a name="output_href"></a> [href](#output\_href) | The URL (href) of the replica file share |
| <a name="output_id"></a> [id](#output\_id) | The unique identifier of the replica file share |
| <a name="output_iops"></a> [iops](#output\_iops) | The maximum IOPS for the replica file share |
| <a name="output_lifecycle_state"></a> [lifecycle\_state](#output\_lifecycle\_state) | The lifecycle state of the replica file share. |
| <a name="output_name"></a> [name](#output\_name) | The unique name of the replica file share within the region. |
| <a name="output_profile"></a> [profile](#output\_profile) | The storage profile used by the replica file share. |
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | The resource group ID that owns the replica file share |
| <a name="output_resource_type"></a> [resource\_type](#output\_resource\_type) | The resource type of the replica file share |
| <a name="output_size"></a> [size](#output\_size) | The capacity of the replica file share in GB. |
| <a name="output_tags"></a> [tags](#output\_tags) | User tags associated with the replica file share |
| <a name="output_zone"></a> [zone](#output\_zone) | The zone in which the replica file share resides. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
