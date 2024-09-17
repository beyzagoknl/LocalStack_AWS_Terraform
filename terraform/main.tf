# File: terraform/main.tf

module "eks_vpc" {
  source = "./modules/eks_vpc"

  region                 = "us-east-1"
  use_localstack         = false
  localstack_endpoint    = ""
  availability_zones     = ["us-east-1a", "us-east-1b"]
  vpc_cidr_block         = "10.0.0.0/16"
  public_subnet_count    = 2
  private_subnet_count   = 2
  cluster_name           = "new-cluster"
  ecr_repo_name          = "hello-world-repo-unique"
  eks_role_name          = "eks-role-unique"
  node_group_role_name   = "node-group-role-unique"
  node_group_name        = "new-node-group"
  node_group_desired_size = 2
  node_group_max_size    = 2
  node_group_min_size    = 1
}
