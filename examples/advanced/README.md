# Advanced example

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<p>
  <a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=vpc-file-storage-advanced-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-vpc-file-storage/tree/main/examples/advanced">
    <img src="https://img.shields.io/badge/Deploy%20with%20IBM%20Cloud%20Schematics-0f62fe?style=flat&logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics">
  </a><br>
  ℹ️ Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab.
</p>
<!-- END SCHEMATICS DEPLOY HOOK -->

<!-- There is a pre-commit hook that will take the title of each example add include it in the repos main README.md  -->
<!-- Add text below should describe exactly what resources are provisioned / configured by the example  -->

An end-to-end advance example that will provision the following:
- A new resource group if one is not passed in.
- A new VPC with 1 subnet
- A VSI instance in the subnet with required security group attached to it
- A file storage instance with security group access control mode
- A cross Regional Replica of the file Storage instance
