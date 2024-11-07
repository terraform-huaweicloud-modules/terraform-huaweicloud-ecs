resource "random_password" "this" {
  length           = 16
  special          = true
  min_numeric      = 1
  min_special      = 1
  min_lower        = 1
  min_upper        = 1
  override_special = "!#"
}

data "huaweicloud_availability_zones" "this" {}

module "vpc_service" {
  source = "github.com/terraform-huaweicloud-modules/terraform-huaweicloud-vpc"

  vpc_name              = var.vpc_name
  vpc_cidr              = var.vpc_cidr
  subnets_configuration = var.subnets_configuration
  security_group_name   = var.security_group_name
}

module "ecs_service" {
  source = "../.."

  availability_zone  = data.huaweicloud_availability_zones.this.names[0]

  instance_flavor_cpu_core_count = var.instance_flavor_cpu_core_count
  instance_flavor_memory_size    = var.instance_flavor_memory_size
  instance_image_is_whole        = true
  instance_image_name            = var.instance_image_name
  instance_name                  = var.instance_name

  instance_admin_pass         = random_password.this.result
  instance_security_group_ids = [module.vpc_service.security_group_id]
  instance_networks_configuration = [
    {
      uuid = try(module.vpc_service.subnet_ids[0], "")
    }
  ]
  instance_disks_configuration = var.instance_disks_configuration
}
