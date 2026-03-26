output "file_share" {
  description = "Details for the file storage instance created"
  value = {
    id                               = ibm_is_share.share.id
    crn                              = ibm_is_share.share.crn
    name                             = ibm_is_share.share.name
    zone                             = ibm_is_share.share.zone
    profile                          = ibm_is_share.share.profile
    size                             = ibm_is_share.share.size
    iops                             = ibm_is_share.share.iops
    access_control_mode              = ibm_is_share.share.access_control_mode
    allowed_transit_encryption_modes = ibm_is_share.share.allowed_transit_encryption_modes
  }
}

output "replica" {
  description = "Details for the file storage replica created "
  value = local.is_replica ? {
    id                    = ibm_is_share.share.id
    crn                   = ibm_is_share.share.crn
    name                  = ibm_is_share.share.name
    zone                  = ibm_is_share.share.zone
    profile               = ibm_is_share.share.profile
    replication_cron_spec = ibm_is_share.share.replication_cron_spec
  } : null
}
output "mount_targets" {
  description = "Mount targets that were created and attached to this file storage instance."
  value = {
    vpc_targets = [
      for mt in values(ibm_is_share_mount_target.mount_targets) : {
        id         = mt.id
        name       = mt.name
        share      = mt.share
        vpc        = mt.vpc
        mount_path = mt.mount_path
      } if length(coalesce(mt.virtual_network_interface, [])) == 0
    ]

    security_group_targets = [
      for mt in values(ibm_is_share_mount_target.mount_targets) : {
        id                      = mt.id
        name                    = mt.name
        share                   = mt.share
        transit_encryption_mode = mt.transit_encryption
        mount_path              = mt.mount_path
        vni = {
          id              = try(mt.virtual_network_interface[0].id, null)
          name            = try(mt.virtual_network_interface[0].name, null)
          subnet_id       = try(mt.virtual_network_interface[0].subnet, null)
          resource_group  = try(mt.virtual_network_interface[0].resource_group, null)
          security_groups = try(mt.virtual_network_interface[0].security_groups, null)
          primary_ip_name = try(mt.virtual_network_interface[0].primary_ip[0].name, null)
          reserved_ip     = try(mt.virtual_network_interface[0].primary_ip[0].reserved_ip, null)
          address         = try(mt.virtual_network_interface[0].primary_ip[0].address, null)
        }
      } if length(coalesce(mt.virtual_network_interface, [])) > 0
    ]
  }
}

output "snapshot_restore" {
  description = "Snapshot restore share details (populated only when create_share.mode == \"snapshot\")."
  value = local.is_snapshot_restore ? {
    id              = ibm_is_share.share.id
    crn             = ibm_is_share.share.crn
    name            = ibm_is_share.share.name
    zone            = ibm_is_share.share.zone
    profile         = ibm_is_share.share.profile
    size            = ibm_is_share.share.size
    iops            = ibm_is_share.share.iops
    source_snapshot = ibm_is_share.share.source_snapshot
  } : null
}

output "accessor_share" {
  description = "Accessor share details (populated only when create_share.mode == \"accessor\")."
  value = local.is_accessor ? {
    id           = ibm_is_share.share.id
    crn          = ibm_is_share.share.crn
    name         = ibm_is_share.share.name
    zone         = ibm_is_share.share.zone
    profile      = ibm_is_share.share.profile
    origin_share = ibm_is_share.share.origin_share
  } : null
}
