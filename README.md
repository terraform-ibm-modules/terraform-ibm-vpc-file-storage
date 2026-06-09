# File Storage for VPC module


[![Graduated (Supported)](https://img.shields.io/badge/Status-Graduated%20(Supported)-brightgreen)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-vpc-file-storage?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-vpc-file-storage/releases/latest)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![Terraform Registry](https://img.shields.io/badge/terraform-registry-623CE4?logo=terraform)](https://registry.terraform.io/modules/terraform-ibm-modules/vpc-file-storage/ibm/latest)


Use this module to provision and configure an IBM [File Storage for VPC](https://cloud.ibm.com/docs/vpc?group=about-file-storage) instance


<!-- The following content is automatically populated by the pre-commit hook -->
<!-- BEGIN OVERVIEW HOOK -->
## Overview
<ul>
  <li><a href="#terraform-ibm-vpc-file-storage">terraform-ibm-vpc-file-storage</a></li>
  <li><a href="https://github.com/terraform-ibm-modules/terraform-ibm-vpc-file-storage/tree/main/modules">Submodules</a>
    <ul>
      <li><a href="https://github.com/terraform-ibm-modules/terraform-ibm-vpc-file-storage/tree/main/modules/accessor">accessor</a></li>
      <li><a href="https://github.com/terraform-ibm-modules/terraform-ibm-vpc-file-storage/tree/main/modules/replica">replica</a></li>
      <li><a href="https://github.com/terraform-ibm-modules/terraform-ibm-vpc-file-storage/tree/main/modules/snapshot_restore">snapshot_restore</a></li>
      <li><a href="https://github.com/terraform-ibm-modules/terraform-ibm-vpc-file-storage/tree/main/modules/standard">standard</a></li>
    </ul>
  </li>
  <li><a href="https://github.com/terraform-ibm-modules/terraform-ibm-vpc-file-storage/tree/main/examples">Examples</a>
    <ul>
      <li>
        <a href="https://github.com/terraform-ibm-modules/terraform-ibm-vpc-file-storage/tree/main/examples/accessor_share">Accessor share example</a>
        <a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=vpc-file-storage-accessor_share-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-vpc-file-storage/tree/main/examples/accessor_share"><img src="https://img.shields.io/badge/Deploy%20with%20IBM%20Cloud%20Schematics-0f62fe?style=flat&logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom; margin-left: 5px;"></a>
      </li>
      <li>
        <a href="https://github.com/terraform-ibm-modules/terraform-ibm-vpc-file-storage/tree/main/examples/advanced">Advanced example</a>
        <a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=vpc-file-storage-advanced-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-vpc-file-storage/tree/main/examples/advanced"><img src="https://img.shields.io/badge/Deploy%20with%20IBM%20Cloud%20Schematics-0f62fe?style=flat&logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom; margin-left: 5px;"></a>
      </li>
      <li>
        <a href="https://github.com/terraform-ibm-modules/terraform-ibm-vpc-file-storage/tree/main/examples/basic">Basic example</a>
        <a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=vpc-file-storage-basic-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-vpc-file-storage/tree/main/examples/basic"><img src="https://img.shields.io/badge/Deploy%20with%20IBM%20Cloud%20Schematics-0f62fe?style=flat&logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom; margin-left: 5px;"></a>
      </li>
      <li>
        <a href="https://github.com/terraform-ibm-modules/terraform-ibm-vpc-file-storage/tree/main/examples/snapshot_restore">Snapshot restore example</a>
        <a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=vpc-file-storage-snapshot_restore-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-vpc-file-storage/tree/main/examples/snapshot_restore"><img src="https://img.shields.io/badge/Deploy%20with%20IBM%20Cloud%20Schematics-0f62fe?style=flat&logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom; margin-left: 5px;"></a>
      </li>
    </ul>
    ℹ️ Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab.
  </li>
  <li><a href="#known-issues">Known issues</a></li>
  <li><a href="#contributing">Contributing</a></li>
</ul>
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

module "file_storage" {
  source                   = "terraform-ibm-modules/vpc-file-storage/ibm"
  version                  = "X.Y.Z" # Replace "X.Y.Z" with a release version to lock into a specific release
  name                     = "file-storage-instance-name"
  resource_group_id        = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX" # Replace with the actual ID of resource group to use
  allowed_access_protocols = [ "nfs4" ]
  size                     = 10
  iops                     = 100
  zone                     = "us-south-1"
  vpc_mount_targets = {
    "primary" = {
      name   = "vpc-target"
      vpc_id =  "79cxxxx-xxxx-xxxx-xxxx-xxxxxXX8667"
    }
  }
}

module "replica" {
  source    = "terraform-ibm-modules/vpc-file-storage/ibm"
  version   = "X.Y.Z" # Replace "X.Y.Z" with a release version to lock into a specific release
  mode      = "replica"
  name      = "zonal-replica"
  zone      = "us-south-2"
  id        = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"  # Replace with the actual ID of the file storage instance to create replica for
  cron_spec = "0 */5 * * *"
}

module "cross_regional_replica" {
  source                 = "terraform-ibm-modules/vpc-file-storage/ibm"
  version                = "X.Y.Z" # Replace "X.Y.Z" with a release version to lock into a specific release
  mode                   = "replica"
  name                   = "cross-regional-replica"
  zone                   = "us-east-2"
  crn                    = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"  # Replace with the actual CRN of the file storage instance to create replica for
  cron_spec              = "0 */5 * * *"
  cross_regional_replica = true
}

module "snapshot_restored_file_storage" {
  source                   = "terraform-ibm-modules/vpc-file-storage/ibm"
  version                  = "X.Y.Z" # Replace "X.Y.Z" with a release version to lock into a specific release
  mode                     = "snapshot_restore"
  name                     = "snapshot-restored"
  allowed_access_protocols = [ "nfs4" ]
  resource_group_id        = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"
  crn                      = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"  # Replace with the actual CRN of the file storage instance
  snapshot_restore         = {

          snapshot_name = "snap1"
          create_snapshot_if_missing = true
  }
}

module "accessor" {
  source            = "terraform-ibm-modules/vpc-file-storage/ibm"
  version           = "X.Y.Z" # Replace "X.Y.Z" with a release version to lock into a specific release
  name              = "file-storage-instance-name"
  mode              = "accessor"
  crn               = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"  # Replace with the actual CRN of the file storage instance in another account to create accessor binding for
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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_accessor"></a> [accessor](#module\_accessor) | ./modules/accessor | n/a |
| <a name="module_replica"></a> [replica](#module\_replica) | ./modules/replica | n/a |
| <a name="module_snapshot_restore"></a> [snapshot\_restore](#module\_snapshot\_restore) | ./modules/snapshot_restore | n/a |
| <a name="module_standard"></a> [standard](#module\_standard) | ./modules/standard | n/a |

### Resources

| Name | Type |
|------|------|
| [ibm_is_share_mount_target.mount_targets](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_share_mount_target) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_tags"></a> [access\_tags](#input\_access\_tags) | A list of access tags to apply to the Files Storage resources created by the module. For more information refer [here](https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial). | `list(string)` | `[]` | no |
| <a name="input_allowed_access_protocols"></a> [allowed\_access\_protocols](#input\_allowed\_access\_protocols) | Allowed network file access protocol used the file storage instance. Note: the only supported values are `nfs4`. [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_share#example-share-create-a-regional-file-share) | `string` | `null` | no |
| <a name="input_cron_spec"></a> [cron\_spec](#input\_cron\_spec) | The cron specification expression for the file share replication schedule. Required when creating a replica share | `string` | `null` | no |
| <a name="input_cross_regional_replica"></a> [cross\_regional\_replica](#input\_cross\_regional\_replica) | Set true, if provisioning the replica file share in a zone that is in a different region than the source file share. Note : source file share and its cross-regional replica must be in the same account. | `bool` | `false` | no |
| <a name="input_initial_owner_gid"></a> [initial\_owner\_gid](#input\_initial\_owner\_gid) | Initial owner group ID (GID) applied to the root directory of the file share when mounted.[know more](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-vpc-about#FS-supplemental-ids). | `number` | `null` | no |
| <a name="input_initial_owner_uid"></a> [initial\_owner\_uid](#input\_initial\_owner\_uid) | Initial owner user ID (UID) applied to the root directory of the file share when mounted. [know more](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-vpc-about#FS-supplemental-ids). | `number` | `null` | no |
| <a name="input_iops"></a> [iops](#input\_iops) | The maximum input/output operation performance bandwidth per second for the file share. refer [here](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-profiles&interface=ui#file-storage-profile-overview). | `number` | `null` | no |
| <a name="input_kms_encryption_enabled"></a> [kms\_encryption\_enabled](#input\_kms\_encryption\_enabled) | Whether to use key management service key encryption to encrypt data in File storage instance  , if set to `false` IBM-managed keys are used by default. | `bool` | `false` | no |
| <a name="input_kms_key_crn"></a> [kms\_key\_crn](#input\_kms\_key\_crn) | The CRN of the key management service key to encrypt the data in the File Storage instance. | `string` | `null` | no |
| <a name="input_mode"></a> [mode](#input\_mode) | Determines which type of file share to create:<br/>  - standard         : Provisions a brand-new, empty file share in a specific zone.<br/>  - snapshot\_restore : Provisions a new file share by restoring data from an existing point-in-time snapshot.<br/>  - accessor         : Creates a cross-account binding (accessor share) to an existing file share, allowing access across different IBM Cloud accounts.<br/>  - replica          : Creates a read-only copy of an existing file share for disaster recovery or data distribution purposes. | `string` | `"standard"` | no |
| <a name="input_name"></a> [name](#input\_name) | The unique name used to identify the file storage for vpc instance. | `string` | `"share"` | no |
| <a name="input_profile"></a> [profile](#input\_profile) | Storage profile with which the file storage instance will be created. [know more](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-profiles&interface=ui) | `string` | `"dp2"` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The ID of the IBM Cloud resource group where the file storage instance will be provisioned. | `string` | `null` | no |
| <a name="input_sg_mount_targets"></a> [sg\_mount\_targets](#input\_sg\_mount\_targets) | Map of Security-group based mount targets for the file share. If a value is provided for this the file storage is created with 'security\_group' access\_control\_mode .[know more](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-vpc-about#fs-mount-access-mode). | <pre>map(object({<br/>    name   = string<br/>    vni_id = optional(string)<br/><br/>    # VNI prototype args (used when vni_id is not set)<br/>    subnet_id                     = optional(string)<br/>    security_group_ids            = optional(list(string), [])<br/>    resource_group_id             = optional(string)<br/>    protocol_state_filtering_mode = optional(string)<br/><br/>    # Reserved IP / Primary IP options<br/>    primary_ip = optional(object({<br/>      reserved_ip = optional(string)<br/>      auto_delete = optional(bool, true)<br/>      address     = optional(string)<br/>      name        = optional(string)<br/>    }))<br/><br/>    # Mount target settings<br/>    transit_encryption = optional(string, "none")<br/>    access_protocol    = optional(string, "nfs4")<br/>  }))</pre> | `{}` | no |
| <a name="input_size"></a> [size](#input\_size) | File share size (capacity) in GB for this file storage for vpc instance. Size requirements vary based on the selected profile refer [here](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-profiles&interface=ui#file-storage-profile-overview). | `number` | `null` | no |
| <a name="input_skip_iam_share_authorization_policy"></a> [skip\_iam\_share\_authorization\_policy](#input\_skip\_iam\_share\_authorization\_policy) | When using an existing KMS instance name, set this value to true if authorization is already enabled between KMS instance and the VPC file share. Otherwise, default is set to false. Ensuring proper authorization avoids access issues during deployment. For more information on how to create authorization policy manually, see [creating authorization policies for VPC file share](https://cloud.ibm.com/docs/vpc?topic=vpc-file-s2s-auth&interface=ui). | `bool` | `false` | no |
| <a name="input_snapshot_restore"></a> [snapshot\_restore](#input\_snapshot\_restore) | Snapshot restore settings to select the source snapshot by ID/CRN/name and optionally create the snapshot if the snapshot identified by snapshot\_name does not exist before restoring. (used only when mode is 'snapshot\_restore'). | <pre>object({<br/>    snapshot_id                = optional(string)<br/>    snapshot_crn               = optional(string)<br/>    snapshot_name              = optional(string)<br/>    create_snapshot_if_missing = optional(bool, false)<br/>  })</pre> | `null` | no |
| <a name="input_source_crn"></a> [source\_crn](#input\_source\_crn) | The Cloud Resource Name (CRN) of the source file share. This is mandatory for 'accessor', and 'replica' modes to identify the parent or reference share. It must be null when creating a 'standard' share. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | List of tags to apply to resources created by this module. | `list(string)` | `[]` | no |
| <a name="input_vpc_mount_targets"></a> [vpc\_mount\_targets](#input\_vpc\_mount\_targets) | Map of VPC mount targets for the file share . If a value is provided for this the file storage is created with 'vpc' access\_control\_mode .[know more](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-vpc-about#fs-mount-access-mode). | <pre>map(object({<br/>    vpc_id = string<br/>    name   = string<br/>  }))</pre> | `{}` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | The specific availability zone (e.g., us-south-1) where the file share resides. To find zones available for each region refer [here](https://cloud.ibm.com/docs/vpc?topic=vpc-vpc-reference&interface=cli#zones-list). | `string` | `null` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_file_share"></a> [file\_share](#output\_file\_share) | Details of the file share created for the selected mode. |
| <a name="output_mount_targets"></a> [mount\_targets](#output\_mount\_targets) | Mount targets that were created and attached to this file storage instance. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Known issues

<!-- Update this if any known issues or limitations -->
There are currently no known issues or limitations at this time.

<!-- Leave this section as is so that your module has a link to local development environment set-up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
