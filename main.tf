data "huaweicloud_compute_flavors" "this" {
  count = var.is_instance_create && (var.instance_flavor_id == "" || var.instance_flavor_id == null) ? 1 : 0

  availability_zone = var.availability_zone
  performance_type  = var.instance_flavor_performance_type # With a default value 'normal'
  cpu_core_count    = var.instance_flavor_cpu_core_count != 0 ? var.instance_flavor_cpu_core_count : null
  memory_size       = var.instance_flavor_memory_size != 0 ? var.instance_flavor_memory_size : null
}

locals {
  all_flavors_with_minimum_vcpu = [for o in data.huaweicloud_compute_flavors.this[0].flavors: o if o.cpu_core_count == try(min([for o in data.huaweicloud_compute_flavors.this[0].flavors: o.cpu_core_count]...), 0)]
  flavor_ids_with_minimum_vcpu_and_memory = [for o in local.all_flavors_with_minimum_vcpu: o.id if o.memory_size == try(min([for o in local.all_flavors_with_minimum_vcpu: o.memory_size]...), 0)]
}

# This data source is valid only when creating an ECS instance.
# This data source has the following functions:
# - When filter parameters such as ID or name are entered, verify the validity of the input items (including the matching with the specifications when
#   the image type is not a whole machine) and query and return the corresponding image list.
# - When filter parameters such as ID or name are missing, return a list of all images that match the specifications.
data "huaweicloud_images_images" "this" {
  count = var.is_instance_create ? 1 : 0

  # Used to query the whole image or ensure the image match the flavor.
  image_id = var.instance_image_id != "" ? var.instance_image_id : null
  # Field name_regex is conflict with field name
  name           = var.instance_image_name != "" ? var.instance_image_name : null
  name_regex     = var.instance_image_name_regex != "" ? var.instance_image_name_regex : null
  image_type     = var.instance_image_type != "" ? var.instance_image_type : null
  is_whole_image = var.instance_image_is_whole
  owner          = var.instance_image_owner != "" ? var.instance_image_owner : null
  os             = var.instance_image_os_type != "" ? var.instance_image_os_type : null
  architecture   = var.instance_image_architecture != "" ? var.instance_image_architecture : null
  visibility     = var.instance_image_visibility != "" ? var.instance_image_visibility : null
  # There is unnecessary to ensure images match the flavor while whole image is used.
  flavor_id = var.instance_image_is_whole == true ? null : var.instance_flavor_id != "" && var.instance_flavor_id != null ? var.instance_flavor_id : try(local.flavor_ids_with_minimum_vcpu_and_memory[0], null)

  lifecycle {
    precondition {
      condition     = !(var.instance_image_is_whole == true && (var.instance_image_id == "" || var.instance_image_id == null) && (var.instance_image_name == "" || var.instance_image_name == null))
      error_message = "The field 'instance_image_id' or field 'instance_image_name' is required if whole image is used."
    }
    precondition {
      condition     = !(var.instance_image_is_whole != true && (var.instance_flavor_id == "" || var.instance_flavor_id == null) && try(local.flavor_ids_with_minimum_vcpu_and_memory[0], "") == "")
      error_message = "The field 'instance_flavor_id' input and the query of the 'huaweicloud_compute_flavors' data source are both empty, which is illegal if the target image is not whole image. Please check the field 'instance_flavor_id' input or filter parameter."
    }
  }
}

locals {
  query_image_id        = try(data.huaweicloud_images_images.this[0].images[0].id, "")
  query_image_backup_id = try(data.huaweicloud_images_images.this[0].images[0].backup_id, "")
}

# This data source is only used to restore its data through the data disk backup of the whole machine image and mount it to the ECS instance.
data "huaweicloud_cbr_backup" "this" {
  count = var.is_instance_create && var.instance_image_is_whole == true && local.query_image_backup_id != "" ? 1 : 0

  id = (var.instance_image_id != "" && var.instance_image_id != null) ? var.instance_image_id : local.query_image_backup_id
}

locals {
  system_disk_configuration = try([for o in var.instance_disks_configuration: o if lookup(o, "is_system_disk")][0], [])
  # Non-mirrored backup data disk configuration.
  custom_data_disks_configuration  = [for o in var.instance_disks_configuration: o if !lookup(o, "is_system_disk")]
  # All data disk configurations, including newly created data disks and data disks restored by the whole image's backup configuration.
  data_disks_configuration = var.instance_image_is_whole == true && local.query_image_backup_id != "" ? tolist(setunion(local.custom_data_disks_configuration,
    try([for i, o in [for o in flatten(data.huaweicloud_cbr_backup.this[0].children): o if !o.extend_info[0].bootable]: tomap({
      "name"        = var.restore_data_disks_name_prefix != "" && var.restore_data_disks_name_prefix != null ? format("%s-%d", var.restore_data_disks_name_prefix, i) : format("restored-volume-%d", i)
      "type"        = var.restore_data_disks_type != "" && var.restore_data_disks_type != null ? var.restore_data_disks_type : "SSD"
      "size"        = o.resource_size
      "snapshot_id" = o.extend_info[0].snapshot_id
      "kms_key_id"  = null
      "iops"        = null
      "throughput"  = null
      "dss_pool_id" = null
    })]), [])) : local.custom_data_disks_configuration
}

resource "huaweicloud_compute_instance" "this" {
  count = var.is_instance_create ? 1 : 0

  name               = var.instance_name
  flavor_id          = var.instance_flavor_id != "" ? var.instance_flavor_id : try(data.huaweicloud_compute_flavors.this[0].flavors[0].id, null)
  image_id           = local.query_image_id
  security_group_ids = length(var.instance_security_group_ids) > 0 ? var.instance_security_group_ids : null
  availability_zone  = var.availability_zone

  # Basic configuration
  description = var.instance_description != "" ? var.instance_description : null
  hostname    = var.instance_hostname != "" ? var.instance_hostname : null
  agency_name = var.instance_agency_name != "" ? var.instance_agency_name : null
  agent_list  = var.instance_agent_list != "" ? var.instance_agent_list : null
  metadata    = length(var.instance_metadata) > 0 ? var.instance_metadata : null
  tags        = length(var.instance_tags) > 0 ? var.instance_tags : null

  # Configuration for log in setting
  user_id     = var.instance_user_id != "" ? var.instance_user_id : null
  admin_pass  = var.instance_admin_pass != "" ? var.instance_admin_pass : null
  user_data   = var.instance_user_data != "" ? var.instance_user_data : null
  key_pair    = var.instance_key_pair != "" ? var.instance_key_pair : null
  private_key = var.instance_private_key != "" ? var.instance_private_key : null

  # Public configuration
  enterprise_project_id = var.enterprise_project_id

  # Configuration of all disks
  system_disk_type        = lookup(local.system_disk_configuration, "type")
  system_disk_size        = lookup(local.system_disk_configuration, "size")
  system_disk_kms_key_id  = lookup(local.system_disk_configuration, "kms_key_id")
  system_disk_iops        = lookup(local.system_disk_configuration, "iops")
  system_disk_throughput  = lookup(local.system_disk_configuration, "throughput")
  system_disk_dss_pool_id = lookup(local.system_disk_configuration, "dss_pool_id")

  dynamic "data_disks" {
    for_each = var.use_inside_data_disks_configuration ? local.data_disks_configuration : []

    content {
      type        = data_disks.value["type"]
      size        = data_disks.value["size"]
      snapshot_id = data_disks.value["snapshot_id"]
      kms_key_id  = data_disks.value["kms_key_id"]
      iops        = data_disks.value["iops"]
      throughput  = data_disks.value["throughput"]
      dss_pool_id = data_disks.value["dss_pool_id"]
    }
  }

  # Related configuration for network setting
  # Private networks
  dynamic "network" {
    for_each = var.instance_networks_configuration

    content {
      uuid              = network.value["uuid"]
      fixed_ip_v4       = network.value["fixed_ip_v4"]
      ipv6_enable       = network.value["ipv6_enable"]
      source_dest_check = network.value["source_dest_check"]
      access_network    = network.value["access_network"]
    }
  }

  # Public network
  eip_id   = var.instance_eip_id != "" ? var.instance_eip_id : null
  eip_type = var.instance_eip_type != "" ? var.instance_eip_type : null
  dynamic "bandwidth" {
    for_each = var.instance_bandwidth_configuration

    content {
      share_type   = bandwidth.value["share_type"]
      size         = bandwidth.value["id"] != "" && bandwidth.value["id"] != null ? null : bandwidth.value["size"]
      id           = bandwidth.value["id"]
      charge_mode  = bandwidth.value["charge_mode"]
      extend_param = bandwidth.value["extend_param"]
    }
  }

  # Scheduler configuraiton
  dynamic "scheduler_hints" {
    for_each = var.instance_scheduler_hints_configuration

    content {
      group   = scheduler_hints.value["group"]
      tenancy = scheduler_hints.value["tenancy"]
      deh_id  = scheduler_hints.value["deh_id"]
    }
  }

  # Related configuration for controlling resource deletion
  stop_before_destroy         = var.instance_stop_before_destroy
  delete_disks_on_termination = var.instance_delete_disks_on_termination
  delete_eip_on_termination   = var.instance_delete_eip_on_termination
  auto_terminate_time         = var.instance_auto_terminate_time

  # Charing mode and related configurations
  charging_mode       = var.instance_charging_mode != "" ? var.instance_charging_mode : null
  period_unit         = var.instance_period_unit != "" ? var.instance_period_unit : null
  period              = var.instance_period != 0 ? var.instance_period : null
  auto_renew          = var.instance_auto_renew != "" ? var.instance_auto_renew : null
  spot_maximum_price  = var.instance_spot_maximum_price != "" ? var.instance_spot_maximum_price : null
  spot_duration       = var.instance_spot_duration != "" ? var.instance_spot_duration : null
  spot_duration_count = var.instance_spot_duration_count != "" ? var.instance_spot_duration_count : null

  # One time action parameter
  power_action = var.instance_power_action != "" ? var.instance_power_action : null

  lifecycle {
    precondition {
      condition     = var.is_instance_create && (var.instance_name != "" && var.instance_name != null)
      error_message = "The field 'instance_name' is required when creating the instance."
    }
    precondition {
      condition     = var.is_instance_create && (var.availability_zone != "" && var.availability_zone != null)
      error_message = "The field 'availability_zone' is required when creating the instance."
    }
    precondition {
      condition     = (var.instance_flavor_id != "" && var.instance_flavor_id != null) || try(local.flavor_ids_with_minimum_vcpu_and_memory[0], "") != ""
      error_message = "The query parameters of the data source 'huaweicloud_compute_flavors' are invalid, and an empty qeury result is found."
    }
    precondition {
      condition     = local.query_image_id != ""
      error_message = "The image is not found, please check the query parameter."
    }
    precondition {
      condition     = var.is_instance_create && length(var.instance_networks_configuration) > 0
      error_message = "The field 'instance_networks_configuration' is required when creating the instance."
    }
    precondition {
      condition     = !(var.instance_eip_id != "" && length(var.instance_networks_configuration) > 0)
      error_message = "Field 'instance_eip_id' and field 'instance_networks_configuration' cannot be configured at the same time."
    }
    precondition {
      condition     = (var.instance_eip_type != "" && length(var.instance_bandwidth_configuration) > 0) || (var.instance_eip_type == "" && length(var.instance_bandwidth_configuration) < 1)
      error_message = "Field 'instance_eip_type' and field 'instance_bandwidth_configuration' must be configured at the same time."
    }
    precondition {
      condition     = !(var.instance_charging_mode == "prePaid" && var.instance_key_pair != "" && var.instance_user_id == "")
      error_message = "Field 'user_id' is required if field 'key_pair' is used and the value of 'charging_mode' is 'prePaid'."
    }
    precondition {
      condition     = !(var.instance_user_data != "" && var.instance_admin_pass != "")
      error_message = "If the 'user_data' field is used for a Linux ECS that is created using an image with Cloud-Init installed, the 'admin_pass' field becomes invalid."
    }
  }
}

resource "huaweicloud_evs_volume" "this" {
  count = var.is_instance_create && !var.use_inside_data_disks_configuration ? length(local.data_disks_configuration) : 0

  availability_zone    = var.availability_zone

  name                 = lookup(element(local.data_disks_configuration, count.index), "name") != "" ? lookup(element(local.data_disks_configuration, count.index), "name") : null
  volume_type          = lookup(element(local.data_disks_configuration, count.index), "type") != "" ? lookup(element(local.data_disks_configuration, count.index), "type") : null
  size                 = lookup(element(local.data_disks_configuration, count.index), "size") != 0 ? lookup(element(local.data_disks_configuration, count.index), "size") : null
  snapshot_id          = lookup(element(local.data_disks_configuration, count.index), "snapshot_id") != "" ? lookup(element(local.data_disks_configuration, count.index), "snapshot_id") : null
  kms_id               = lookup(element(local.data_disks_configuration, count.index), "kms_key_id") != "" ? lookup(element(local.data_disks_configuration, count.index), "kms_key_id") : null
  iops                 = lookup(element(local.data_disks_configuration, count.index), "iops") != 0 ? lookup(element(local.data_disks_configuration, count.index), "iops") : null
  throughput           = lookup(element(local.data_disks_configuration, count.index), "throughput") != 0 ? lookup(element(local.data_disks_configuration, count.index), "throughput") : null
  dedicated_storage_id = lookup(element(local.data_disks_configuration, count.index), "dss_pool_id") != "" ? lookup(element(local.data_disks_configuration, count.index), "dss_pool_id") : null
}

resource "huaweicloud_compute_volume_attach" "this" {
  count = var.is_instance_create && !var.use_inside_data_disks_configuration ? length(local.data_disks_configuration) : 0

  instance_id = huaweicloud_compute_instance.this[0].id
  volume_id   = huaweicloud_evs_volume.this[count.index].id
}
