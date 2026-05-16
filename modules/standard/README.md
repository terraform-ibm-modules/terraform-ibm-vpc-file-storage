# File Storage for VPC standard module

You can use this submodule to provision and configure [File Storage for VPC](https://cloud.ibm.com/docs/vpc?group=about-file-storage) instance. This module will also create required KMS authorization polices if an existing encryption key is provided.


### Usage
```hcl

module "file_storage" {
  source                              = "terraform-ibm-modules/vpc-file-storage/ibm//modules/standard"
  version                             = "X.Y.Z" # Replace "X.Y.Z" with a release version to lock into a specific release
  name                                = "file-storage-instance-name"
  size                                = 10
  iops                                = 100
  resource_group_id                   = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"
  zone                                = "us-south-1"
  access_control_mode                 = "security_group"
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
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.88.0, < 3.0.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.1, < 1.0.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_existing_kms_key_crn_parser"></a> [existing\_kms\_key\_crn\_parser](#module\_existing\_kms\_key\_crn\_parser) | terraform-ibm-modules/common-utilities/ibm//modules/crn-parser | 1.5.0 |

### Resources

| Name | Type |
|------|------|
| [ibm_iam_authorization_policy.file_share_policy](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_is_share.share](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_share) | resource |
| [time_sleep.wait_for_authorization_policy](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_control_mode"></a> [access\_control\_mode](#input\_access\_control\_mode) | Controls how the mount target authorizes access to the file share (security\_group for Security Group based access, or vpc for same-zone VPC access).[Learn more](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-vpc-about#fs-mount-access-mode). | `string` | `null` | no |
| <a name="input_access_tags"></a> [access\_tags](#input\_access\_tags) | A list of access tags to apply to the Files Storage resources created by the module. For more information refer [here](https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial). | `list(string)` | `[]` | no |
| <a name="input_allowed_access_protocols"></a> [allowed\_access\_protocols](#input\_allowed\_access\_protocols) | Allowed access protocol for the file storage instance. Note: the only supported values are `nfs4`. [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_share#example-share-create-a-regional-file-share) | `string` | `"nfs4"` | no |
| <a name="input_initial_owner_gid"></a> [initial\_owner\_gid](#input\_initial\_owner\_gid) | Initial owner group ID (GID) applied to the root directory of the file share when mounted.[learn more](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-vpc-about#FS-supplemental-ids). | `number` | `100` | no |
| <a name="input_initial_owner_uid"></a> [initial\_owner\_uid](#input\_initial\_owner\_uid) | Initial owner user ID (UID) applied to the root directory of the file share when mounted. [learn more](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-vpc-about#FS-supplemental-ids). | `number` | `10000` | no |
| <a name="input_iops"></a> [iops](#input\_iops) | The maximum input/output operation performance bandwidth per second for the file share. refer [here](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-profiles&interface=ui#file-storage-profile-overview). | `number` | `100` | no |
| <a name="input_kms_encryption_enabled"></a> [kms\_encryption\_enabled](#input\_kms\_encryption\_enabled) | Whether to use key management service key encryption to encrypt data in File storage instance  , if set to `false` IBM-managed keys are used by default. | `bool` | `false` | no |
| <a name="input_kms_key_crn"></a> [kms\_key\_crn](#input\_kms\_key\_crn) | The CRN of the key management service key to encrypt the data in the File Storage instance. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | The unique name used to identify the file storage for vpc instance. | `string` | `"share"` | no |
| <a name="input_profile"></a> [profile](#input\_profile) | Storage profile with which the file storage instance will be created. [learn more](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-profiles&interface=ui). | `string` | `"dp2"` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The ID of the IBM Cloud resource group where the file storage instance will be provisioned. | `string` | `null` | no |
| <a name="input_size"></a> [size](#input\_size) | File share size (capacity) in GB for this file storage for vpc instance. refer [here](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-profiles&interface=ui#file-storage-profile-overview). | `number` | `10` | no |
| <a name="input_skip_iam_share_authorization_policy"></a> [skip\_iam\_share\_authorization\_policy](#input\_skip\_iam\_share\_authorization\_policy) | When using an existing KMS instance name, set this value to true if authorization is already enabled between KMS instance and the VPC file share. Otherwise, default is set to false. Ensuring proper authorization avoids access issues during deployment.For more information on how to create authorization policy manually, see [creating authorization policies for VPC file share](https://cloud.ibm.com/docs/vpc?topic=vpc-file-s2s-auth&interface=ui). | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | List of tags to apply to resources created by this module. | `list(string)` | `[]` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | The specific availability zone (e.g., us-south-1) where the file share resides. To find zones available for each region refer [here](https://cloud.ibm.com/docs/vpc?topic=vpc-vpc-reference&interface=cli#zones-list). | `string` | `null` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_control_mode"></a> [access\_control\_mode](#output\_access\_control\_mode) | The access control mode for the file share. |
| <a name="output_access_tags"></a> [access\_tags](#output\_access\_tags) | Access management tags associated with the file share. |
| <a name="output_allowed_transit_encryption_modes"></a> [allowed\_transit\_encryption\_modes](#output\_allowed\_transit\_encryption\_modes) | The transit encryption modes allowed for this file share. |
| <a name="output_created_at"></a> [created\_at](#output\_created\_at) | The RFC3339 timestamp when the file share was created. |
| <a name="output_crn"></a> [crn](#output\_crn) | The Cloud Resource Name (CRN) of the file share. |
| <a name="output_encryption"></a> [encryption](#output\_encryption) | The type of encryption used for this file share. |
| <a name="output_href"></a> [href](#output\_href) | The URL (href) of the file share. |
| <a name="output_id"></a> [id](#output\_id) | The unique identifier of the file share. |
| <a name="output_iops"></a> [iops](#output\_iops) | The maximum IOPS for the file share. |
| <a name="output_lifecycle_state"></a> [lifecycle\_state](#output\_lifecycle\_state) | The lifecycle state of the file share. |
| <a name="output_name"></a> [name](#output\_name) | The unique name of the file share within the region. |
| <a name="output_profile"></a> [profile](#output\_profile) | The storage profile used by the file share. |
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | The resource group ID that owns the file share. |
| <a name="output_resource_type"></a> [resource\_type](#output\_resource\_type) | The resource type of the file share. |
| <a name="output_size"></a> [size](#output\_size) | The capacity of the file share in GB. |
| <a name="output_tags"></a> [tags](#output\_tags) | User tags associated with the file share. |
| <a name="output_zone"></a> [zone](#output\_zone) | The zone in which the file share resides. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
