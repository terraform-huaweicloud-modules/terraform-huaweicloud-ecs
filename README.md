# The Terraform module of HUAWEI Cloud ECS service

The terraform module for one-click deployment of ECS instance.

## Usage

### Create an ECS instance by public image

```hcl
variable "availability_zone" {}
variable "enterprise_project_id" {}
variable "instance_flavor_cpu_core_count" {}
variable "instance_flavor_memory_size" {}
variable "instance_image_os_type" {}
variable "instance_image_architecture" {}
variable "instance_name" {}
variable "admin_password" {}
variable "security_group_ids" {}
variable "vpc_subnet_id" {}
variable "instance_disks_configuration" {}

module "ecs_service" {
  source = "terraform-huaweicloud-modules/terraform-huaweicloud-ecs"

  availability_zone     = data.huaweicloud_availability_zones.this.names[0]
  enterprise_project_id = var.enterprise_project_id

  instance_flavor_cpu_core_count  = var.instance_flavor_cpu_core_count
  instance_flavor_memory_size     = var.instance_flavor_memory_size
  instance_image_os_type          = var.instance_image_os_type
  instance_image_architecture     = var.instance_image_architecture
  instance_name                   = var.instance_name
  instance_admin_pass             = var.admin_password
  instance_security_group_ids     = var.security_group_ids
  instance_networks_configuration = [
    {
      uuid = var.vpc_subnet_id
    }
  ]
  use_inside_data_disks_configuration = true
  instance_disks_configuration        = var.instance_disks_configuration
}
```

### Create an ECS instance by the whole image

```hcl
variable "availability_zone" {}
variable "enterprise_project_id" {}
variable "instance_flavor_cpu_core_count" {}
variable "instance_flavor_memory_size" {}
variable "instance_image_name" {}
variable "instance_name" {}
variable "admin_password" {}
variable "security_group_ids" {}
variable "vpc_subnet_id" {}
variable "instance_disks_configuration" {}

module "ecs_service" {
  source = "terraform-huaweicloud-modules/terraform-huaweicloud-ecs"

  availability_zone     = data.huaweicloud_availability_zones.this.names[0]
  enterprise_project_id = var.enterprise_project_id

  instance_flavor_cpu_core_count  = var.instance_flavor_cpu_core_count
  instance_flavor_memory_size     = var.instance_flavor_memory_size
  instance_image_is_whole        = true
  instance_image_name            = var.instance_image_name
  
  instance_name                   = var.instance_name
  instance_admin_pass             = var.admin_password
  instance_security_group_ids     = var.security_group_ids
  instance_networks_configuration = [
    {
      uuid = var.vpc_subnet_id
    }
  ]
  instance_disks_configuration = var.instance_disks_configuration
}
```

## Contributing

Report issues/questions/feature requests in the [issues](https://github.com/terraform-huaweicloud-modules/terraform-huaweicloud-ecs/issues/new)
section.

Full contributing [guidelines are covered here](.github/how_to_contribute.md).

## Requirements

| Name | Version |
|------|---------|
| Terraform | >= 1.3.0 |
| Huaweicloud Provider | >= 1.40.0 |

## Resources

| Name | Type |
|------|------|
| data.huaweicloud_compute_flavors.this | data-source |
| data.huaweicloud_images_images.this | data-source |
| data.huaweicloud_cbr_backup.this | data-source |
| huaweicloud_compute_instance.this | resource |
| huaweicloud_evs_volume.this | resource |
| huaweicloud_compute_volume_attach.this | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| enterprise_project_id | The enterprise project ID to which the instance belongs | string | "" | N |
| availability_zone | The availability zone to which the instance resource belongs | string | "" | N |
| instance_flavor_performance_type | The performance type of the instance flavor to be queried | string | "normal" | N |
| instance_flavor_cpu_core_count | The CPU core number of the instance flavor to be queried | number | 0 | N |
| instance_flavor_memory_size | The memory size of the instance flavor to be queried | number | 0 | N |
| instance_image_name | The name of the IMS image to be queried that the instance used | string | "" | N |
| instance_image_name_regex | The regular expression for name that will be used to match the IMS images | string | "" | N |
| instance_image_type | The environment where the IMS image is used | string | "" | N |
| instance_image_is_whole | Whether the IMS image is the whole image | bool | null | N |
| instance_image_owner | The owner (UUID) of the IMS image to be queried that the instance used | string | "" | N |
| instance_image_os_type | The OS type of the IMS image to be queried that the instance used | string | "" | N |
| instance_image_architecture | The architecture of the IMS image to be queried that the instance used | string | "" | N |
| instance_image_visibility | The visibility of the IMS image to be queried that the instance used | string | "" | N |
| is_instance_create | Control whether an instance should be created (it affects all instance related resources under this module) | bool | true | N |
| instance_name | The name of the instance resource | string | "" | N |
| instance_flavor_id | The ID of the instance flavor | string | "" | N |
| instance_image_id | The IMS image ID of the instance resource | string | "" | N |
| instance_security_group_ids | The list of security group IDs to which the instance resource belongs | list(string) | <pre>[]</pre> | N |
| instance_description | The description of the instance resource | string | "" | N |
| instance_hostname | The host name of the instance resource | string | "" | N |
| instance_agency_name | The IAM agency name which is created on IAM to provide temporary credentials for ECS to access cloud services | string | "" | N |
| instance_agent_list | The agent list in comma-separated string | string | "" | N |
| instance_metadata | The user-defined metadata key-value pairs | map(string) | <pre>{}</pre> | N |
| instance_tags | The key/value pairs to associate with the instance | map(string) | <pre>{}</pre> | N |
| instance_user_id | The user ID, required when using key_pair in prePaid charging mode | string | "" | N |
| instance_admin_pass | The administrator password of the instance resource | string | "" | N |
| instance_user_data | The user data to be injected to the instance during the creation | string | "" | N |
| instance_key_pair | The SSH keypair name used for logging in to the instance | string | "" | N |
| instance_private_key | The the private key of the keypair in use | string | "" | N |
| instance_key_pair | The SSH keypair name used for logging in to the instance | string | "" | N |
| use_inside_data_disks_configuration | Whether to allow data disks to be created together with ECS instance | bool | false | N |
| restore_data_disks_name_prefix | The name prefix of data disks restored from the whole image | string | "" (restored-volume-N by logic default) | N |
| restore_data_disks_type | The type of data disks restored from the whole image | string | "" (SSD by logic default) | N |
| data_disks_configuration | The configuration of data disks of the ECS instance | list(object({<br>  is_system_disk = bool<br>  name           = optional(string, "")<br>  type           = string<br>  size        = number<br>  snapshot_id    = optional(string, "")<br>  kms_key_id     = optional(string, "")<br>  iops          = optional(number, 0)<br>  throughput     = optional(number, 0)<br>  dss_pool_id    = optional(string, "")<br>})) | <pre>[<br>  {<br>    is_system_disk = true,<br>    type = "SSD",<br>    size = 200<br>}] | N |
| instance_networks_configuration | The private networks configuration to attach to the instance resource | list(object({<br>    uuid              = string<br>    fixed_ip_v4       = optional(string, "")<br>    ipv6_enable       = optional(bool, null)<br>    source_dest_check = optional(bool, null)<br>    access_network    = optional(bool, null)<br>  })) | <pre>[]</pre> | N |
| instance_eip_id | The ID of an existing EIP assigned to the instance | string | "" | N |
| instance_eip_type | The type of an EIP that will be automatically assigned to the instance | string | "" | N |
| instance_bandwidth_configuration | The bandwidth configuration of an EIP that will be automatically assigned to the instance | list(object({<br>    share_type   = optional(string, "")<br>    size         = optional(number, 0)<br>    id           = optional(string, "")<br>    charge_mode  = optional(string, "")<br>    extend_param = optional(map(string), {})<br>  })) | <pre>[]</pre> | N |
| instance_scheduler_hints_configuration | The scheduler with hints on how the instance should be launched | list(object({<br>    group   = optional(string, "")<br>    tenancy = optional(string, "")<br>    deh_id  = optional(string, "")<br>  })) | <pre>[]</pre> | N |
| instance_stop_before_destroy | Whether to try stop instance gracefully before destroying it, thus giving chance for guest OS daemons to stop correctly | bool | false | N |
| instance_delete_disks_on_termination | Whether to delete the data disks when the instance is terminated | bool | false | N |
| instance_delete_eip_on_termination | Whether the EIP is released when the instance is terminated | bool | false | N |
| instance_auto_terminate_time | The auto terminate time | string | "" | N |
| instance_charging_mode | The charging mode of the instance | string | "" | N |
| instance_period_unit | The charging period unit of the instance | string | "" | N |
| instance_period | The charging period of the instance | number | 0 | N |
| instance_auto_renew | Whether the order of the instance is automatically renewed | string | "" | N |
| instance_spot_maximum_price | The highest price per hour you accept for a spot instance | string | "" | N |
| instance_spot_duration | The service duration of the spot instance in hours | string | "" | N |
| instance_spot_duration_count | The number of time periods in the service duration | string | "" | N |
| instance_power_action | The power action to be done for the instance | string | "" | N |

## Outputs

| Name | Description |
|------|-------------|
| instance_id | The ID of the first ECS instance |
| instance_status | The status of the first ECS instance |
| instance_public_ip | The public IP of the first ECS instance |
| instance_access_ipv4 | The fixed IPv4 address or the floating IP of the first ECS instance |
| instance_access_ipv6 | The fixed IPv6 address of the first ECS instance |
| instance_network | The network object of the first ECS instance |
