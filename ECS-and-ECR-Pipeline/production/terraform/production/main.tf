# VPC Module - Provision VPC with public and private subnets
module "vpc" {
  source          = "../modules/vpc"
  app_name        = var.app_name
  environment     = var.environment
  region          = var.region
  container_port  = var.container_port
}

# ALB Module - Deploy ALB in public subnets and associate with ECS services
module "alb" {
  source              = "../modules/alb"
  vpc_id              = module.vpc.vpc_id 
  app_name            = var.app_name
  environment         = var.environment
  certificate_arn     = var.certificate_arn
  security_group_ids  = module.vpc.security_group_ids  # Using VPC's security group
  subnet_ids          = module.vpc.public_subnet_ids     # ALB should be in public subnets
  health_check_path   = var.health_check_path

  depends_on = [ module.vpc ]  # Ensure VPC is created before ALB
}

# ECS Module - Deploy ECS tasks in private subnets and link to ALB
module "ecs" {
  source                = "../modules/ecs"
  app_name              = var.app_name
  environment           = var.environment
  container_port        = var.container_port
  region                = var.region
  subnet_ids            = module.vpc.private_subnet_ids    # ECS tasks should run in private subnets
  security_group_ids    = module.vpc.security_group_ids
  alb_target_group_arn  = module.alb.alb_target_group_arn  # Use ALB target group from ALB module
  
  depends_on = [ module.alb ]  # Ensure ALB is created before ECS service
}

# Autoscaling Module - Attach autoscaling policies to ECS service
module "autoscaling" {
  source            = "../modules/autoscaling"
  app_name          = var.app_name
  environment       = var.environment
  min_capacity      = var.min_capacity
  max_capacity      = var.max_capacity
  ecs_cluster_name  = module.ecs.ecs_cluster_id       # Pass ECS cluster name from ECS module
  ecs_service_name  = module.ecs.ecs_service_name     # Pass ECS service name from ECS module

  depends_on = [ module.ecs ]  # Ensure ECS service is created before autoscaling
}