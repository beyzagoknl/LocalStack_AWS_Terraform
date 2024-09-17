variable "region" {
  description = "The AWS region to deploy into"
  type        = string
}

variable "use_localstack" {
  description = "Flag to use localstack for local development"
  type        = bool
  default     = false
}

variable "localstack_endpoint" {
  description = "Localstack endpoint URL"
  type        = string
  default     = ""
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_count" {
  description = "Number of public subnets"
  type        = number
}

variable "private_subnet_count" {
  description = "Number of private subnets"
  type        = number
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "ecr_repo_name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "eks_role_name" {
  description = "Name of the EKS IAM role"
  type        = string
}

variable "node_group_role_name" {
  description = "Name of the EKS node group IAM role"
  type        = string
}

variable "node_group_name" {
  description = "Name of the EKS node group"
  type        = string
}

variable "node_group_desired_size" {
  description = "Desired size for the EKS node group"
  type        = number
}

variable "node_group_max_size" {
  description = "Maximum size for the EKS node group"
  type        = number
}

variable "node_group_min_size" {
  description = "Minimum size for the EKS node group"
  type        = number
}
