output "instance_id" {
  description = "The ID of the ECS instance"

  value = module.ecs_service.instance_id
}

output "instance_status" {
  description = "The status of the ECS instance"

  value = module.ecs_service.instance_status
}
