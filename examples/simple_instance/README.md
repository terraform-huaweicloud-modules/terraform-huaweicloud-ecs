# Simple instance

Configuration in this directory creates a simple ECS instance.
This ECS instance has the following configuration:

- Post Pay billing
- 4U8G specifications
- x86 CentOS image
- 1 SSD 200G system disk
- 1 SSD 100G data disk
- 1 SSD 150G data disk

Referring to this use case, you can write a simple ECS script.

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example will create an instance and spend a few money. Run `terraform destory` when you don't need them.

## Requirement

| Name | Version |
|------|---------|
| Terraform | >= 1.3.0 |
| HuaweiCloud | >= 1.40.0 |
| Random | >= 3.0.0 |

## Providers

[terraform-provider-huaweicloud](https://github.com/huaweicloud/terraform-provider-huaweicloud)

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecs"></a>[ecs](#module\_ecs) | [../..](../../README.md) | N/A |
| vpc | [terraform-huaweicloud-vpc](https://github.com/terraform-huaweicloud-modules/terraform-huaweicloud-vpc) | N/A |

## Resources

| Name | Type |
|------|------|
| random_password.this[0] | resource |
| module.vpc_service.huaweicloud_vpc.this[0] | resource |
| module.vpc_service.huaweicloud_vpc_subnet.this[0] | resource |
| module.vpc_service.huaweicloud_networking_secgroup.this[0] | resource |
| module.vpc_service.huaweicloud_networking_secgroup_rule.in_v4_self_group[0] | resource |
| module.vpc_service.huaweicloud_networking_secgroup_rule.this[0] | resource |
| module.vpc_service.data.huaweicloud_networking_secgroup_rules.this[0] | data source |
| module.ecs_service.huaweicloud_compute_instance.this[0] | resource |

## Inputs

| Name | Description | Type | value |
|------|-------------|------|---------------|
| enterprise_project_id | Used to specify whether the resource is created under the enterprise project (this parameter is only valid for enterprise users) | string | "0" |
| vpc_name | The name of the VPC to which the ECS instance belongs | string | "demo" |
| vpc_cidr | The CIDR of the VPC to which the ECS instance belongs | string | "192.168.0.0/16" |
| subnets_configuration | The configuration of the subnet resources to which the ECS instance belongs | <pre>list(object({<br>  name = string<br>  cidr = string<br>}))</pre> | <pre>[<br>  {<br>    "name": "demo",<br>    "cidr": "192.168.0.0/20"<br>  }<br>]</pre> |
| security_group_name | The name of the security group to which the ECS instance belongs | string | "demo" |
| instance_flavor_cpu_core_count | The CPU core number of the instance flavor to be queried | string | 4 |
| instance_flavor_memory_size | The memory size of the instance flavor to be queried | string | 8 |
| instance_image_os_type | The OS type of the IMS image to be queried that the instance used | string | "CentOS" |
| instance_image_architecture | The architecture of the IMS image to be queried that the instance used | string | "x86" |
| instance_name | The name of the ECS instance | string | "demo" |
| use_inside_data_disks_configuration | "Whether to allow data disks to be created together with ECS instance" | bool | true |
| instance_disks_configuration | The data disks configuration to attach to the instance resource | <pre>list(object({<br>  is_system_disk = bool<br>  name           = optional(string, "")<br>  type           = string<br>  size           = number<br>}))</pre> | <pre>[<br>  {<br>    is_system_disk = true,<br>    type           = "SSD",<br>    size           = 200<br>  },<br>  {<br>    is_system_disk = false,<br>    name           = "data-disk-demo-0",<br>    type           = "SSD",<br>    size           = 100<br>  },<br>  {<br>    is_system_disk = false,<br>    name           = "data-disk-demo-1",<br>    type           = "SSD",<br>    size           = 150<br>  }<br>]</pre> |

## Outputs

| Name | Description |
|------|-------------|
| instance_id | The ID of the ECS instance |
| instance_status | The status of the ECS instance |
