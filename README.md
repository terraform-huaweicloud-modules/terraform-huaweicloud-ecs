# The Terraform module of HUAWEI Cloud ECS service

The terraform module for one-click deployment of ECS instance.

## Usage

```hcl
variable "subnet_id" {}
variable "security_group_ids" {}
variable "flavor_id" {}
variable "image_id" {}
variable "system_disk_type" {}
variable "system_disk_size" {}
variable "admin_password" {}
variable "data_disks_configuration" {}

data "huaweicloud_availability_zones" "test" {}

module "ecs_service" {
  source = "terraform-huaweicloud-modules/terraform-huaweicloud-ecs"

  subnet_id          = var.subnet_id
  security_group_ids = var.security_group_ids
  availability_zone  = data.huaweicloud_availability_zones.test.names[0]

  instance_name            = var.instance_name
  flavor_id                = var.flavor_id
  image_id                 = var.image_id
  system_disk_type         = var.system_disk_type
  system_disk_size         = var.system_disk_size
  admin_password           = var.admin_password
  data_disks_configuration = var.data_disks_configuration
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
| huaweicloud_compute_flavors.this | data-source |
| huaweicloud_images_image.this | data-source |
| huaweicloud_compute_instance.this | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| charging_mode | The charging mode of the ECS resources | string | null | N |
| period_unit | The period unit of the pre-paid purchase | string | null | N |
| period | The period number of the pre-paid purchase | number | null | N |
| is_auto_renew | Whether to automatically renew after expiration for ECS resources | bool | null | N |
| name_suffix | The suffix string of name for all ECS resources | string | null | N |
| subnet_id | The ID of the VPC subnet to which the ECS instance belongs | string | null | N |
| security_group_ids | The ID list of the security groups to which the ECS instance belongs | list(string) | [] | N |
| availability_zone | The specified availability zone where the ECS instance is located | string | null | N |
| is_instance_create | Controls whether a ECS instance should be created (it affects all ECS related resources under this module) | bool | true | N |
| instance_count | The total number of the ECS instances | number | 0 | N |
| instance_name | The name of the ECS instance | string | null | N |
| flavor_id | The ID of the ECS instance flavor | string | null | N |
| instance_flavor_performance | The performance type of the ECS instance flavor | string | null | N |
| instance_flavor_cpu | The CPU number of the ECS instance flavor | number | null | N |
| instance_flavor_memory | The memory number of the ECS instance flavor | number | null | N |
| image_id | The ID of the IMS image that ECS instance used | string | null | N |
| instance_image_name | The name of the IMS image that ECS instance used | string | null | N |
| system_disk_type | The type of the system volume | string | "SSD" | N |
| system_disk_size | The size of the system volume, in GB | number | 40 | N |
| eip_id | The ID of the EIP assigned to the ECS instance | string | null | N |
| admin_password | The login password of the administrator | string | null | N |
| user_data | The user data to be injected during the ECS instance creation | string | null | N |
| scheduler_hints_configuration | The scheduler with hints on how instance should be launched | <pre>list(object({<br>  group   = string<br>  tenancy = string<br>  deh_id  = string<br>})</pre> | [] | N |
| stop_before_destroy | Whether to try stop instance gracefully before destroying it, thus giving chance for guest OS daemons to stop correctly | bool | true | N |
| delete_disks_on_termination | Whether to delete the data disks when the instance is terminated | bool | true | N |
| delete_eip_on_termination | Whether to release the EIP when the instance is terminated | bool | true | N |
| fixed_ip_v4 | The fixed IP address that ECS instance have | string | null | N |
| ipv6_enable | Whether to enable the IPv6 network | bool | false | N |
| source_dest_check | Whether the ECS processes only traffic that is destined specifically for it | bool | false | N |
| access_network | Whether network should be used for provisioning access | bool | false | N |
| scheduler_hints_configuration | The scheduler with hints on how instance should be launched | <pre>list(object({<br>  type        = string<br>  size        = number<br>  snapshot_id = string<br>})</pre> | <pre>[<br>  {<br>    type = "SSD"<br>    size = 200<br>  }<br>]</pre> | N |
| instance_tags | The key/value pairs of the ECS instance | map(string) | {} | N |
| keypair_name | The name of the key-pair for encryption and login ECS instance | string | null | N |

## Outputs

| Name | Description |
|------|-------------|
| instance_ids | The ID list of the ECS instances |
| instance_id | The ID of the first ECS instance |
