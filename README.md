<!-- Update this title with a descriptive name. Use sentence case. -->
# File Storage for VPC module

<!--
Update status and "latest release" badges:
  1. For the status options, see https://terraform-ibm-modules.github.io/documentation/#/badge-status
  2. Update the "latest release" badge to point to the correct module's repo. Replace "terraform-ibm-module-template" in two places.
  3. Update the Terraform Registry badge to point to the correct published module path (replace "module-template" with the actual module name before release).
-->
[![Incubating (Not yet consumable)](https://img.shields.io/badge/status-Incubating%20(Not%20yet%20consumable)-red)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-module-template?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-module-template/releases/latest)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![Terraform Registry](https://img.shields.io/badge/terraform-registry-623CE4?logo=terraform)](https://registry.terraform.io/modules/terraform-ibm-modules/module-template/ibm/latest)
<!--
Add a description of modules in this repo.
Expand on the repo short description in the .github/settings.yml file.

For information, see "Module names and descriptions" at
https://terraform-ibm-modules.github.io/documentation/#/implementation-guidelines?id=module-names-and-descriptions
-->

Use this module to provision and configure an IBM [File Storage for VPC](https://cloud.ibm.com/docs/vpc?group=about-file-storage) instance

<!-- The following content is automatically populated by the pre-commit hook -->
<!-- BEGIN OVERVIEW HOOK -->
## Overview
* [terraform-ibm-vpc-file-storage](#terraform-ibm-vpc-file-storage)
* [Examples](./examples)
:information_source: Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab
    * <a href="./examples/advanced">Advanced example</a> <a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=vpc-file-storage-advanced-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-vpc-file-storage/tree/main/examples/advanced"><img src="https://img.shields.io/badge/Deploy%20with IBM%20Cloud%20Schematics-0f62fe?logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom; margin-left: 5px;"></a>
    * <a href="./examples/basic">Basic example</a> <a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=vpc-file-storage-basic-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-vpc-file-storage/tree/main/examples/basic"><img src="https://img.shields.io/badge/Deploy%20with IBM%20Cloud%20Schematics-0f62fe?logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom; margin-left: 5px;"></a>
* [Known issues](#known-issues)
* [Contributing](#contributing)
<!-- END OVERVIEW HOOK -->


<!-- Replace this heading with the name of the root level module (the repo name) -->
## terraform-ibm-vpc-file-storage

### Usage

<!--
Add an example of the use of the module in the following code block.

Use real values instead of "var.<var_name>" or other placeholder values
unless real values don't help users know what to change.
-->

```hcl

provider "ibm" {
  ibmcloud_api_key = "XXXXXXXXXX"  # replace with apikey value
  region           = local.region
}

module "module_template" {
  source            = "terraform-ibm-modules/<replace>/ibm"
  version           = "X.Y.Z" # Replace "X.Y.Z" with a release version to lock into a specific release
  region            = local.region
  name              = "instance-name"
  resource_group_id = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX" # Replace with the actual ID of resource group to use
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

<!-- The following content is automatically populated by the pre-commit hook -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.80.0, < 2.0.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.1, < 1.0.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_existing_kms_key_crn_parser"></a> [existing\_kms\_key\_crn\_parser](#module\_existing\_kms\_key\_crn\_parser) | terraform-ibm-modules/common-utilities/ibm//modules/crn-parser | 1.4.1 |

### Resources

| Name | Type |
|------|------|
| [ibm_iam_authorization_policy.file_share_policy](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_is_share.accessor](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/is_share) | resource |
| [ibm_is_share.replica](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/is_share) | resource |
| [ibm_is_share.share](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/is_share) | resource |
| [ibm_is_share.snapshot_restore](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/is_share) | resource |
| [ibm_is_share_mount_target.share_target_sg](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/is_share_mount_target) | resource |
| [ibm_is_share_mount_target.share_target_vpc](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/is_share_mount_target) | resource |
| [time_sleep.wait_for_authorization_policy](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_tags"></a> [access\_tags](#input\_access\_tags) | A list of access tags to apply to the Filse Storage resources created by the module. For more information, see https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial. | `list(string)` | `[]` | no |
| <a name="input_enable_snapshot_restore"></a> [enable\_snapshot\_restore](#input\_enable\_snapshot\_restore) | Set to true if restoring from a snapshot | `bool` | `false` | no |
| <a name="input_encryption_key_crn"></a> [encryption\_key\_crn](#input\_encryption\_key\_crn) | Encryption key CRN for file share encryption | `string` | `null` | no |
| <a name="input_initial_owner_gid"></a> [initial\_owner\_gid](#input\_initial\_owner\_gid) | GID for the root of the file share. Use >= 100 (preferably >= 10000) to avoid reserved ranges. | `number` | `10000` | no |
| <a name="input_initial_owner_uid"></a> [initial\_owner\_uid](#input\_initial\_owner\_uid) | UID for the root of the file share. Use >= 10000 to avoid reserved ranges. | `number` | `10000` | no |
| <a name="input_iops"></a> [iops](#input\_iops) | The maximum input/output operation performance bandwidth per second for the file share. | `number` | `null` | no |
| <a name="input_kms_encryption_enabled"></a> [kms\_encryption\_enabled](#input\_kms\_encryption\_enabled) | Enable Key management , if set to `false` IBM-managed keys are used by default | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Base name for the file share | `string` | `null` | no |
| <a name="input_origin_share_crn"></a> [origin\_share\_crn](#input\_origin\_share\_crn) | CRN of origin file share. Required when creating cross account accessor Share | `string` | `null` | no |
| <a name="input_profile"></a> [profile](#input\_profile) | File storage profiles | `string` | `"dp2"` | no |
| <a name="input_replica_cron_spec"></a> [replica\_cron\_spec](#input\_replica\_cron\_spec) | Replica schedule cron spec | `string` | `null` | no |
| <a name="input_replica_name"></a> [replica\_name](#input\_replica\_name) | Replica share name | `string` | `null` | no |
| <a name="input_replica_zone"></a> [replica\_zone](#input\_replica\_zone) | Replica zone | `string` | `null` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | ID of resource group to provision file storage. | `string` | `null` | no |
| <a name="input_sg_mount_targets"></a> [sg\_mount\_targets](#input\_sg\_mount\_targets) | Security-group based mount targets . If set the file storage is created with Security Group access mode | <pre>list(object({<br/>    subnet_id          = string<br/>    security_group_ids = list(string)<br/>    transit_encryption = optional(string, "none")<br/>  }))</pre> | `[]` | no |
| <a name="input_size"></a> [size](#input\_size) | Size in GB. The size of the file share | `number` | `null` | no |
| <a name="input_skip_iam_share_authorization_policy"></a> [skip\_iam\_share\_authorization\_policy](#input\_skip\_iam\_share\_authorization\_policy) | When using an existing KMS instance name, set this value to true if authorization is already enabled between KMS instance and the VPC file share. Otherwise, default is set to false. Ensuring proper authorization avoids access issues during deployment.For more information on how to create authorization policy manually, see [creating authorization policies for VPC file share](https://cloud.ibm.com/docs/vpc?topic=vpc-file-s2s-auth&interface=ui). | `bool` | `false` | no |
| <a name="input_source_snapshot_crn"></a> [source\_snapshot\_crn](#input\_source\_snapshot\_crn) | If set, create the share by restoring from this snapshot CRN. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | List of tags to apply to resources created by this module. | `list(string)` | `[]` | no |
| <a name="input_vpc_mount_targets"></a> [vpc\_mount\_targets](#input\_vpc\_mount\_targets) | List of VPC IDs to mount file share . If set the file storage is created with VPC access mode | `list(string)` | `[]` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | Region where VPC will be created. To find your VPC region, use `ibmcloud is regions` command to find available regions. | `string` | `null` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_accessor_share"></a> [accessor\_share](#output\_accessor\_share) | Accessor share details. |
| <a name="output_file_share"></a> [file\_share](#output\_file\_share) | File share details. |
| <a name="output_mount_targets"></a> [mount\_targets](#output\_mount\_targets) | Mount target details. |
| <a name="output_snapshot_restore"></a> [snapshot\_restore](#output\_snapshot\_restore) | Snapshot restore share details |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Known issues

<!-- Update this if any known issues or limitations -->
There are currently no known issues or limitations at this time.

<!-- Leave this section as is so that your module has a link to local development environment set-up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
