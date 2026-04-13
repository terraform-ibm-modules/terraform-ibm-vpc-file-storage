output "file_share" {
  description = "Outputs of the file share created for the selected mode."
  value = (
    var.mode == "standard" ? module.standard[0] :
    var.mode == "replica" ? module.replica[0] :
    var.mode == "snapshot_restore" ? module.snapshot_restore[0] :
    null
  )
}

output "mount_targets" {
  description = "Mount targets that were created and attached to this file storage instance."
  value = {
    vpc_targets = [
      for mt in values(ibm_is_share_mount_target.mount_targets) : {
        id                  = mt.id
        name                = mt.name
        share               = mt.share
        vpc                 = mt.vpc
        access_control_mode = mt.access_control_mode
        created_at          = mt.created_at
        href                = mt.href
        lifecycle_state     = mt.lifecycle_state
        resource_type       = mt.resource_type
        mount_path          = try(mt.mount_path, null)
        transit_encryption  = mt.transit_encryption
      } if length(coalesce(mt.virtual_network_interface, [])) == 0
    ]

    security_group_targets = [
      for mt in values(ibm_is_share_mount_target.mount_targets) : {
        id                      = mt.id
        name                    = mt.name
        share                   = mt.share
        transit_encryption_mode = mt.transit_encryption
        mount_path              = mt.mount_path
        access_control_mode     = mt.access_control_mode
        created_at              = mt.created_at
        href                    = mt.href
        lifecycle_state         = mt.lifecycle_state
        resource_type           = mt.resource_type

        vni = {
          id                        = try(mt.virtual_network_interface[0].id, null)
          name                      = try(mt.virtual_network_interface[0].name, null)
          subnet_id                 = try(mt.virtual_network_interface[0].subnet, null)
          resource_group            = try(mt.virtual_network_interface[0].resource_group, null)
          security_groups           = try(mt.virtual_network_interface[0].security_groups, null)
          allow_ip_spoofing         = try(mt.virtual_network_interface[0].allow_ip_spoofing, null)
          auto_delete               = try(mt.virtual_network_interface[0].auto_delete, null)
          enable_infrastructure_nat = try(mt.virtual_network_interface[0].enable_infrastructure_nat, null)
          primary_ip_name           = try(mt.virtual_network_interface[0].primary_ip[0].name, null)
          reserved_ip               = try(mt.virtual_network_interface[0].primary_ip[0].reserved_ip, null)
          address                   = try(mt.virtual_network_interface[0].primary_ip[0].address, null)
        }
      } if length(coalesce(mt.virtual_network_interface, [])) > 0
    ]
  }
}
