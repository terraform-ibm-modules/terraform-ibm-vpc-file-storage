package test

import (
	"fmt"
	"log"
	"os"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/files"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

const resourceGroup = "geretain-test-resources"
const region = "us-south"

const advancedExampleDir = "examples/advanced"
const basicExampleDir = "examples/basic"
const snapshotRestoreExampleDir = "examples/snapshot_restore"

const yamlLocation = "../common-dev-assets/common-go-assets/common-permanent-resources.yaml"

var permanentResources map[string]interface{}

func TestMain(m *testing.M) {

	var err error
	permanentResources, err = common.LoadMapFromYaml(yamlLocation)
	if err != nil {
		log.Fatal(err)
	}

	os.Exit(m.Run())
}

func setupOptions(t *testing.T, prefix string, dir string) *testhelper.TestOptions {
	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  dir,
		Prefix:        prefix,
		Region:        region,
		ResourceGroup: resourceGroup,
	})
	return options
}

func TestRunBasicExample(t *testing.T) {
	t.Parallel()

	Prefix := fmt.Sprintf("fs-%s", strings.ToLower(random.UniqueId()))
	options := setupOptions(t, Prefix, basicExampleDir)

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunUpgradeBasicExample(t *testing.T) {
	t.Parallel()

	Prefix := fmt.Sprintf("fs-%s", strings.ToLower(random.UniqueId()))
	options := setupOptions(t, Prefix, basicExampleDir)

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}

func TestRunAdvancedExample(t *testing.T) {
	t.Parallel()
	Prefix := fmt.Sprintf("adv-%s", strings.ToLower(random.UniqueId()))
	options := setupOptions(t, Prefix, advancedExampleDir)

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunUpgradeAdvancedExample(t *testing.T) {
	t.Parallel()

	Prefix := fmt.Sprintf("adv-upg-%s", strings.ToLower(random.UniqueId()))
	options := setupOptions(t, Prefix, advancedExampleDir)

	options.TerraformVars["kms_encryption_enabled"] = true
	options.TerraformVars["kms_key_crn"] = permanentResources["hpcs_south_root_key_crn"]

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}

func provisionPreReq(t *testing.T) (string, *terraform.Options, error) {
	// ------------------------------------------------------------------------------------
	// Provision existing resources first
	// ------------------------------------------------------------------------------------
	prefix := fmt.Sprintf("%s-t-%s", "fs", strings.ToLower(random.UniqueId()))
	realTerraformDir := ".."
	tempTerraformDir, _ := files.CopyTerraformFolderToTemp(realTerraformDir, fmt.Sprintf(prefix+"-%s", strings.ToLower(random.UniqueId())))
	tags := common.GetTagsFromTravis()

	// Verify ibmcloud_api_key variable is set
	checkVariable := "TF_VAR_ibmcloud_api_key"
	val, present := os.LookupEnv(checkVariable)
	require.True(t, present, checkVariable+" environment variable not set")
	require.NotEqual(t, "", val, checkVariable+" environment variable is empty")

	logger.Log(t, "Tempdir: ", tempTerraformDir)

	existingTerraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: tempTerraformDir + "/tests/existing-resources",
		Vars: map[string]interface{}{
			"prefix":        prefix,
			"region":        region,
			"resource_tags": tags,
		},
		Upgrade: true,
	})

	terraform.Init(t, existingTerraformOptions)
	terraform.WorkspaceSelectOrNew(t, existingTerraformOptions, prefix)
	_, existErr := terraform.InitAndApplyE(t, existingTerraformOptions)
	if existErr != nil {
		// assert.True(t, existErr == nil, "Init and Apply of temp existing resource failed")
		return "", nil, existErr
	}
	return prefix, existingTerraformOptions, nil
}

func TestRunSnapshotRestoreExample(t *testing.T) {
	t.Parallel()
	prefix, existingTerraformOptions, existErr := provisionPreReq(t)

	if existErr != nil {
		assert.True(t, existErr == nil, "Init and Apply of temp existing resource failed")
	} else {

		fileShareCrn := terraform.Output(t, existingTerraformOptions, "file_share_crn")

		logger.Log(t, "source file_share_crn: ", fileShareCrn)

		snapPrefix := fmt.Sprintf("snap-%s", strings.ToLower(random.UniqueId()))
		options := setupOptions(t, snapPrefix, snapshotRestoreExampleDir)
		options.TerraformVars["existing_fileshare_crn"] = fileShareCrn

		output, err := options.RunTestConsistency()
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
	// Check if "DO_NOT_DESTROY_ON_FAILURE" is set
	envVal, _ := os.LookupEnv("DO_NOT_DESTROY_ON_FAILURE")

	if existingTerraformOptions == nil {
		t.Log("Skipping destroy: existingTerraformOptions is nil (provisionPreReq failed)")
		return
	}

	// Destroy the temporary existing resources if required
	if t.Failed() && strings.ToLower(envVal) == "true" {
		fmt.Println("Terratest failed. Debug the test and delete resources manually.")
	} else {
		logger.Log(t, "START: Destroy (existing resources)")
		terraform.Destroy(t, existingTerraformOptions)
		terraform.WorkspaceDelete(t, existingTerraformOptions, prefix)
		logger.Log(t, "END: Destroy (existing resources)")
	}
}

func TestRunUpgradeSnapshotRestoreExample(t *testing.T) {
	t.Parallel()
	prefix, existingTerraformOptions, existErr := provisionPreReq(t)

	if existErr != nil {
		assert.True(t, existErr == nil, "Init and Apply of temp existing resource failed")
	} else {

		fileShareCrn := terraform.Output(t, existingTerraformOptions, "file_share_crn")

		logger.Log(t, "source file_share_crn: ", fileShareCrn)

		snapPrefix := fmt.Sprintf("snap-%s", strings.ToLower(random.UniqueId()))
		options := setupOptions(t, snapPrefix, snapshotRestoreExampleDir)
		options.TerraformVars["existing_fileshare_crn"] = fileShareCrn

		output, err := options.RunTestUpgrade()
		if !options.UpgradeTestSkipped {
			assert.Nil(t, err, "This should not have errored")
			assert.NotNil(t, output, "Expected some output")
		}
	}
	// Check if "DO_NOT_DESTROY_ON_FAILURE" is set
	envVal, _ := os.LookupEnv("DO_NOT_DESTROY_ON_FAILURE")

	if existingTerraformOptions == nil {
		t.Log("Skipping destroy: existingTerraformOptions is nil (provisionPreReq failed)")
		return
	}

	// Destroy the temporary existing resources if required
	if t.Failed() && strings.ToLower(envVal) == "true" {
		fmt.Println("Terratest failed. Debug the test and delete resources manually.")
	} else {
		logger.Log(t, "START: Destroy (existing resources)")
		terraform.Destroy(t, existingTerraformOptions)
		terraform.WorkspaceDelete(t, existingTerraformOptions, prefix)
		logger.Log(t, "END: Destroy (existing resources)")
	}
}
