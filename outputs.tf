output "file_share" {
  description = "File share details."
  value = {
    primary = try(
      {
        id                               = ibm_is_share.share[0].id
        crn                              = ibm_is_share.share[0].crn
        name                             = ibm_is_share.share[0].name
        zone                             = ibm_is_share.share[0].zone
        profile                          = ibm_is_share.share[0].profile
        size                             = ibm_is_share.share[0].size
        iops                             = ibm_is_share.share[0].iops
        access_control_mode              = ibm_is_share.share[0].access_control_mode
        allowed_transit_encryption_modes = ibm_is_share.share[0].allowed_transit_encryption_modes
        encryption_key                   = ibm_is_share.share[0].encryption_key
      },
      null
    )

    replica = try(
      {
        id                    = ibm_is_share.replica[0].id
        crn                   = ibm_is_share.replica[0].crn
        name                  = ibm_is_share.replica[0].name
        zone                  = ibm_is_share.replica[0].zone
        profile               = ibm_is_share.replica[0].profile
        replication_cron_spec = ibm_is_share.replica[0].replication_cron_spec
        source_share          = ibm_is_share.replica[0].source_share
      },
      null
    )
  }
}

output "mount_targets" {
  description = "Mount target details."
  value = {
    vpc_targets = length(ibm_is_share_mount_target.share_target_vpc) > 0 ? [
      for mt in ibm_is_share_mount_target.share_target_vpc : {
        id         = mt.id
        name       = mt.name
        share      = mt.share
        vpc        = mt.vpc
        mount_path = mt.mount_path
      }
    ] : []

    security_group_targets = length(ibm_is_share_mount_target.share_target_sg) > 0 ? [
      for mt in ibm_is_share_mount_target.share_target_sg : {
        id                 = mt.id
        name               = mt.name
        share              = mt.share
        transit_encryption = mt.transit_encryption
        mount_path         = mt.mount_path
        # Inputs used to create VNI
        vni = {
          name            = mt.virtual_network_interface[0].name
          subnet_id       = mt.virtual_network_interface[0].subnet
          resource_group  = mt.virtual_network_interface[0].resource_group
          security_groups = mt.virtual_network_interface[0].security_groups
          primary_ip_name = mt.virtual_network_interface[0].primary_ip[0].name
        }
      }
    ] : []
  }
}


output "snapshot_restore" {
  description = "Snapshot restore share details"
  value = try(
    {
      id      = ibm_is_share.snapshot_restore[0].id
      crn     = ibm_is_share.snapshot_restore[0].crn
      name    = ibm_is_share.snapshot_restore[0].name
      zone    = ibm_is_share.snapshot_restore[0].zone
      profile = ibm_is_share.snapshot_restore[0].profile
      size    = ibm_is_share.snapshot_restore[0].size
    },
    null
  )
}

output "accessor_share" {
  description = "Accessor share details."
  value = try(
    {
      id   = ibm_is_share.accessor[0].id
      crn  = ibm_is_share.accessor[0].crn
      name = ibm_is_share.accessor[0].name
      zone = ibm_is_share.accessor[0].zone
    },
    null
  )
}
