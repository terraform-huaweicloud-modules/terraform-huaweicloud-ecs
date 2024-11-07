######################################################################
# Public configuration
######################################################################

variable "enterprise_project_id" {
  description = "The enterprise project ID to which the instance belongs"

  type    = string
  default = "" # Some accounts do not have the enterprise project enabled.
}

variable "availability_zone" {
  description = "The availability zone to which the instance resource belongs"

  type    = string
  default = ""
}

######################################################################
# Configuration for data sources querying
######################################################################

variable "instance_flavor_performance_type" {
  description = "The performance type of the instance flavor to be queried"

  type    = string
  default = "normal"
}

variable "instance_flavor_cpu_core_count" {
  description = "The CPU core number of the instance flavor to be queried"

  type    = number
  default = 0
}

variable "instance_flavor_memory_size" {
  description = "The memory size of the instance flavor to be queried"

  type    = number
  default = 0
}

variable "instance_image_name" {
  description = "The name of the IMS image to be queried that the instance used"

  type    = string
  default = ""
}

variable "instance_image_name_regex" {
  description = "The regular expression for name that will be used to match the IMS images"

  type    = string
  default = ""
}

variable "instance_image_type" {
  description = "The environment where the IMS image is used"

  type    = string
  default = ""
}

variable "instance_image_is_whole" {
  description = "Whether the IMS image is the whole image"

  type    = bool
  default = false
}

variable "instance_image_owner" {
  description = "The owner (UUID) of the IMS image to be queried that the instance used"

  type    = string
  default = ""
}

variable "instance_image_os_type" {
  description = "The OS type of the IMS image to be queried that the instance used"

  type    = string
  default = ""
}

variable "instance_image_architecture" {
  description = "The architecture of the IMS image to be queried that the instance used"

  type    = string
  default = ""
}

variable "instance_image_visibility" {
  description = "The visibility of the IMS image to be queried that the instance used"

  type    = string
  default = ""
}

######################################################################
# Configuration of ECS instance resource
######################################################################

variable "is_instance_create" {
  description = "Control whether an instance should be created (it affects all instance related resources under this module)"

  type     = bool
  default  = true
  nullable = false
}

variable "instance_name" {
  description = "The name of the instance resource"

  type = string
  default = ""
}

variable "instance_flavor_id" {
  description = "The ID of the instance flavor"

  type    = string
  default = ""
}

variable "instance_image_id" {
  description = "The IMS image ID of the instance resource"

  type    = string
  default = ""
}

variable "instance_security_group_ids" {
  description = "The list of security group IDs to which the instance resource belongs"

  type    = list(string)
  default = []
}

# Basic configuration
variable "instance_description" {
  description = "The description of the instance resource"

  type    = string
  default = ""
}

variable "instance_hostname" {
  description = "The host name of the instance resource"

  type    = string
  default = ""
}

variable "instance_agency_name" {
  description = "The IAM agency name which is created on IAM to provide temporary credentials for ECS to access cloud services"

  type    = string
  default = ""
}

variable "instance_agent_list" {
  description = "The agent list in comma-separated string"

  type    = string
  default = ""
}

variable "instance_metadata" {
  description = "The user-defined metadata key-value pairs"

  type    = map(string)
  default = {}
}

variable "instance_tags" {
  description = "The key/value pairs to associate with the instance"

  type    = map(string)
  default = {}
}

# Configuration for log in setting
variable "instance_user_id" {
  description = "The user ID, required when using key_pair in prePaid charging mode"

  type    = string
  default = ""
}

variable "instance_admin_pass" {
  description = "The administrator password of the instance resource"

  type      = string
  sensitive = true
  default   = ""
}

variable "instance_user_data" {
  description = "The user data to be injected to the instance during the creation"

  type    = string
  default = ""
}

variable "instance_key_pair" {
  description = "The SSH keypair name used for logging in to the instance"

  type    = string
  default = ""
}

variable "instance_private_key" {
  description = "The the private key of the keypair in use"

  type    = string
  default = ""
}

# Configuration of all disks
variable "use_inside_data_disks_configuration" {
  description = "Whether to allow data disks to be created together with ECS instance"

  type     = bool
  default  = false
  nullable = false
}

variable "restore_data_disks_name_prefix" {
  description = "The name prefix of the restored data disks that the instance used"

  type    = string
  default = ""
}

variable "restore_data_disks_type" {
  description = "The type of the restored data disks that the instance used"

  type    = string
  default = ""
}

variable "instance_disks_configuration" {
  description = "The data disks configuration to attach to the instance resource"

  type = list(object({
    is_system_disk = bool
    name           = optional(string, "")
    type           = string
    size           = number
    snapshot_id    = optional(string, "")
    kms_key_id     = optional(string, "")
    iops           = optional(number, 0)
    throughput     = optional(number, 0)
    dss_pool_id    = optional(string, "")
  }))

  default = [
    {
      is_system_disk = true
      type           = "SSD"
      size           = 200
    }
  ]

  validation {
    condition     = length([for o in var.instance_disks_configuration: o if o.is_system_disk]) == 1
    error_message = "The configuration of the system is required and the cannot configure multiple."
  }
  validation {
    condition     = length(var.instance_disks_configuration) > 0 && alltrue([for o in var.instance_disks_configuration: o.snapshot_id == "" || o.snapshot_id == null if o.is_system_disk])
    error_message = "Only data disk can configure the snapshot ID."
  }
}

# Related configuration for network setting
# Private networks
variable "instance_networks_configuration" {
  description = "The private networks configuration to attach to the instance resource"

  type = list(object({
    uuid              = string
    fixed_ip_v4       = optional(string, "")
    ipv6_enable       = optional(bool, null)
    source_dest_check = optional(bool, null)
    access_network    = optional(bool, null)
  }))
  default  = []
  nullable = false
}

# Public network
variable "instance_eip_id" {
  description = "The ID of an existing EIP assigned to the instance"

  type    = string
  default = ""
}

variable "instance_eip_type" {
  description = "The type of an EIP that will be automatically assigned to the instance"

  type    = string
  default = ""
}

variable "instance_bandwidth_configuration" {
  description = "The bandwidth configuration of an EIP that will be automatically assigned to the instance"

  type = list(object({
    share_type   = optional(string, "")
    size         = optional(number, 0)
    id           = optional(string, "")
    charge_mode  = optional(string, "")
    extend_param = optional(map(string), {})
  }))
  default  = []
  nullable = false
}

# Scheduler configuraiton
variable "instance_scheduler_hints_configuration" {
  description = "The scheduler with hints on how the instance should be launched"

  type = list(object({
    group   = optional(string, "")
    tenancy = optional(string, "")
    deh_id  = optional(string, "")
  }))
  default  = []
  nullable = false
}

# Related configuration for controlling resource deletion
variable "instance_stop_before_destroy" {
  description = "Whether to try stop instance gracefully before destroying it, thus giving chance for guest OS daemons to stop correctly"

  type    = bool
  default = null
}

variable "instance_delete_disks_on_termination" {
  description = "Whether to delete the data disks when the instance is terminated"

  type    = bool
  default = null
}

variable "instance_delete_eip_on_termination" {
  description = "Whether the EIP is released when the instance is terminated"

  type    = bool
  default = null
}

variable "instance_auto_terminate_time" {
  description = "The auto terminate time"

  type    = string
  default = ""
}

# Charing mode and related configurations
variable "instance_charging_mode" {
  description = "The charging mode of the instance"

  type    = string
  default = ""
}

variable "instance_period_unit" {
  description = "The charging period unit of the instance"

  type    = string
  default = ""
}

variable "instance_period" {
  description = "The charging period of the instance"

  type    = number
  default = 0
}

variable "instance_auto_renew" {
  description = "Whether the order of the instance is automatically renewed"

  type    = string
  default = ""
}

variable "instance_spot_maximum_price" {
  description = "The highest price per hour you accept for a spot instance"

  type    = string
  default = ""
}

variable "instance_spot_duration" {
  description = "The service duration of the spot instance in hours"

  type    = number
  default = 0
}

variable "instance_spot_duration_count" {
  description = "The number of time periods in the service duration"

  type    = number
  default = 0
}

variable "instance_power_action" {
  description = "The power action to be done for the instance"

  type    = string
  default = ""
}
