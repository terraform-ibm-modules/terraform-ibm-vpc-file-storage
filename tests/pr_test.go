// Tests in this file are run in the PR pipeline and the continuous testing pipeline
package test

import (
	"encoding/json"
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

// Use existing resource group
const resourceGroup = "geretain-test-resources"
const region = "us-south"

// Ensure every example directory has a corresponding test
const advancedExampleDir = "examples/advanced"
const basicExampleDir = "examples/basic"
const snapshotRestoreExampleDir = "examples/snapshot_restore"

const yamlLocation = "../common-dev-assets/common-go-assets/common-permanent-resources.yaml" // Define a struct with fields that match the structure of the YAML data
var permanentResources map[string]interface{}

// TestMain will be run before any parallel tests, used to read data from yaml for use with tests
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

// Consistency test for the basic example
func TestRunBasicExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "fs", basicExampleDir)

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunAdvancedExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "adv", advancedExampleDir)
	options.TerraformVars["kms_encryption_enabled"] = true
	options.TerraformVars["encryption_key_crn"] = permanentResources["hpcs_south_root_key_crn"]

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunUpgradeAdvancedExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "adv-upg", advancedExampleDir)
	options.TerraformVars["kms_encryption_enabled"] = true
	options.TerraformVars["encryption_key_crn"] = permanentResources["hpcs_south_root_key_crn"]

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}

func TestRunSnapshotRestoreExample(t *testing.T) {
	t.Parallel()
	prefix := fmt.Sprintf("%s-t-%s", "fs", strings.ToLower(random.UniqueId()))
	realTerraformDir := ".."
	tempTerraformDir, _ := files.CopyTerraformFolderToTemp(realTerraformDir, fmt.Sprintf(prefix+"-%s", strings.ToLower(random.UniqueId())))

	// Verify ibmcloud_api_key variable is set
	checkVariable := "TF_VAR_ibmcloud_api_key"
	val, present := os.LookupEnv(checkVariable)
	require.True(t, present, checkVariable+" environment variable not set")
	require.NotEqual(t, "", val, checkVariable+" environment variable is empty")

	logger.Log(t, "Tempdir: ", tempTerraformDir)

	// 1) Apply source example first
	sourceOpts := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: tempTerraformDir + "/examples/advanced",
		Vars: map[string]interface{}{
			"prefix": prefix,
			"region": region,
		},
		Upgrade: true,
	})

	_, err := terraform.InitE(t, sourceOpts)
	require.NoError(t, err)

	terraform.WorkspaceSelectOrNew(t, sourceOpts, prefix)

	// Defer source cleanup immediately — runs even if Apply or later steps fail
	defer func() {
		envVal, _ := os.LookupEnv("DO_NOT_DESTROY_ON_FAILURE")
		if t.Failed() && strings.ToLower(envVal) == "true" {
			logger.Log(t, "Terratest failed. Debug the test and delete resources manually.")
			return
		}
		logger.Log(t, "START: Destroy (source resources)")
		terraform.Destroy(t, sourceOpts)
		terraform.WorkspaceDelete(t, sourceOpts, prefix)
		logger.Log(t, "END: Destroy (source resources)")
	}()

	_, err = terraform.ApplyE(t, sourceOpts)
	if err != nil {
		t.Fatalf("Source apply failed, triggering deferred destroy: %v", err)
		// t.Fatalf calls runtime.Goexit(), so deferred funcs still run
	}

	// Extract file_share.crn
	type fileShareOutput struct {
		Crn string `json:"crn"`
	}

	fileShareJSON := terraform.OutputJson(t, sourceOpts, "file_share")

	var fs fileShareOutput
	err = json.Unmarshal([]byte(fileShareJSON), &fs)
	require.NoError(t, err)
	require.NotEmpty(t, fs.Crn)

	logger.Log(t, "source file_share.crn: ", fs.Crn)

	// 2) Apply snapshot_restore example using that CRN
	snapPrefix := fmt.Sprintf("snap-%s", strings.ToLower(random.UniqueId()))
	snapOpts := setupOptions(t, snapPrefix, snapshotRestoreExampleDir)
	snapOpts.TerraformVars["existing_fileshare_crn"] = fs.Crn
	defer func() {
		envVal, _ := os.LookupEnv("DO_NOT_DESTROY_ON_FAILURE")
		if t.Failed() && strings.ToLower(envVal) == "true" {
			// Already logged in the source defer
			return
		}
		logger.Log(t, "START: Destroy (snapshot_restore resources)")
		terraform.Init(t, snapOpts.TerraformOptions)
		terraform.Destroy(t, snapOpts.TerraformOptions)
		logger.Log(t, "END: Destroy (snapshot_restore resources)")
	}()

	output, err := snapOpts.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}
