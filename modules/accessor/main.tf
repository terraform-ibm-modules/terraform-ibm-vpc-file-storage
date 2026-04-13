##############################################################################
# Create Accessor File Share
##############################################################################

resource "ibm_is_share" "accessor" {
  name        = var.name
  tags        = var.tags
  access_tags = var.access_tags

  origin_share {
    id  = (var.source_id != null && trimspace(var.source_id) != "") ? var.source_id : null
    crn = (var.source_crn != null && trimspace(var.source_crn) != "") ? var.source_crn : null
  }
}
