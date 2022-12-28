output "instance_ids" {
  description = "The ID list of the ECS instances"

  value = huaweicloud_compute_instance.this[*].id
}

output "instance_id" {
  description = "The ID of the first ECS instance"

  value = try(huaweicloud_compute_instance.this[0].id, "")
}
