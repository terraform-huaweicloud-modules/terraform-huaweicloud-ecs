######################################################################
# Public configuration
######################################################################

variable "enterprise_project_id" {
  description = "The enterprise project ID to which the instance belongs"

  type = string
}

######################################################################
# Attributes of the VPC resources
######################################################################

variable "vpc_name" {
  description = "The name of the VPC to which the ECS instance belongs"

  type = string
}

variable "vpc_cidr" {
  description = "The CIDR of the VPC to which the ECS instance belongs"

  type = string
}

variable "subnets_configuration" {
  description = "The configuration of the subnet resources to which the ECS instance belongs"

  type    = list(object({
    name = string
    cidr = string
  }))
}

variable "security_group_name" {
  description = "The name of the security group to which the ECS instance belongs"

  type = string
}

######################################################################
# Attributes of the ECS resources
######################################################################

variable "instance_flavor_cpu_core_count" {
  description = "The flavor ID of the instance resource to be queried"

  type = number
}

variable "instance_flavor_memory_size" {
  description = "The flavor ID of the instance resource to be queried"

  type = number
}

variable "instance_image_name" {
  description = "The name of the IMS image to be queried that the instance used"

  type = string
}

variable "instance_name" {
  description = "The name of the ECS instance resource"

  type = string
}

variable "instance_disks_configuration" {
  description = "The data disks configuration to attach to the instance resource"

  type = list(object({
    is_system_disk = bool
    name           = optional(string, "")
    type           = string
    size           = number
  }))
}
