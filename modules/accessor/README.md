# File Storage for VPC accessor module

You can use this submodule to provision and configure [File Storage for VPC accessor share](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-accessor-create&interface=terraform) binding of an existing file storage instance present in another account.


### Usage
```hcl

module "accessor" {
  source      = "terraform-ibm-modules/vpc-file-storage/ibm//modules/accessor"
  version     = "X.Y.Z" # Replace "X.Y.Z" with a release version to lock into a specific release
  name        = "file-storage-instance-name"
  source_crn  = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"  # Replace with the actual CRN of the file storage instance in another account to create accessor binding for
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
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 2.1.0, < 3.0.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [ibm_is_share.accessor](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_share) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_tags"></a> [access\_tags](#input\_access\_tags) | A list of access tags to apply to the Files Storage resources created by the module. For more information refer [here](https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial). | `list(string)` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | The unique name used to identify the file storage for vpc instance. | `string` | `"share"` | no |
| <a name="input_source_crn"></a> [source\_crn](#input\_source\_crn) | The Cloud Resource Name (CRN) of the source file share this source file share CRN is used to identify the cross account file share instance of which the binding needs to be created in the accessor account. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | List of tags to apply to resources created by this module. | `list(string)` | `[]` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_control_mode"></a> [access\_control\_mode](#output\_access\_control\_mode) | The access control mode for the accessor file share. |
| <a name="output_access_tags"></a> [access\_tags](#output\_access\_tags) | Access management tags associated with the accessor file share. |
| <a name="output_allowed_transit_encryption_modes"></a> [allowed\_transit\_encryption\_modes](#output\_allowed\_transit\_encryption\_modes) | The transit encryption modes allowed for this accessor file share. |
| <a name="output_created_at"></a> [created\_at](#output\_created\_at) | The RFC3339 timestamp when the accessor file share was created. |
| <a name="output_crn"></a> [crn](#output\_crn) | The Cloud Resource Name (CRN) of the accessor file share. |
| <a name="output_encryption"></a> [encryption](#output\_encryption) | The type of encryption used for this accessor file share. |
| <a name="output_href"></a> [href](#output\_href) | The URL (href) of the accessor file share. |
| <a name="output_id"></a> [id](#output\_id) | The unique identifier of the accessor file share. |
| <a name="output_iops"></a> [iops](#output\_iops) | The maximum IOPS for the accessor file share. |
| <a name="output_lifecycle_state"></a> [lifecycle\_state](#output\_lifecycle\_state) | The lifecycle state of the accessor file share. |
| <a name="output_name"></a> [name](#output\_name) | The unique name of the accessor file share within the region. |
| <a name="output_profile"></a> [profile](#output\_profile) | The storage profile used by the accessor file share. |
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | The resource group ID that owns the accessor file share. |
| <a name="output_resource_type"></a> [resource\_type](#output\_resource\_type) | The resource type of the accessor file share. |
| <a name="output_size"></a> [size](#output\_size) | The capacity of the accessor file share in GB. |
| <a name="output_source_snapshot"></a> [source\_snapshot](#output\_source\_snapshot) | The origin share this accessor share is referring to. |
| <a name="output_tags"></a> [tags](#output\_tags) | User tags associated with the accessor file share. |
| <a name="output_zone"></a> [zone](#output\_zone) | The zone in which the accessor file share resides. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
