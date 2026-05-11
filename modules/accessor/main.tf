##############################################################################
# Create Accessor File Share
##############################################################################

resource "ibm_is_share" "accessor" {
  name        = var.name
  tags        = var.tags
  access_tags = var.access_tags

  origin_share {
    crn = var.source_crn
  }
}
