locals {
  availability_zones = var.availability_zones
}

provider "aws" {
  region = var.region

  skip_credentials_validation = var.use_localstack ? true : false
  skip_metadata_api_check     = var.use_localstack ? true : false
  skip_requesting_account_id  = var.use_localstack ? true : false

  endpoints {
    eks = var.use_localstack ? var.localstack_endpoint : null
    ec2 = var.use_localstack ? var.localstack_endpoint : null
    ecr = var.use_localstack ? var.localstack_endpoint : null
    iam = var.use_localstack ? var.localstack_endpoint : null
  }
}

resource "aws_vpc" "eks_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "eks-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  count             = var.public_subnet_count
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.0.${count.index}.0/24"
  availability_zone = element(local.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name                              = "public-subnet-${count.index}"
    kubernetes.io/cluster/${var.cluster_name} = "shared"
    kubernetes.io/role/elb            = "1"
  }
}

resource "aws_subnet" "private_subnet" {
  count             = var.private_subnet_count
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.0.${count.index + var.public_subnet_count}.0/24"
  availability_zone = element(local.availability_zones, count.index)

  tags = {
    Name                              = "private-subnet-${count.index}"
    kubernetes.io/cluster/${var.cluster_name} = "shared"
    kubernetes.io/role/internal-elb   = "1"
  }
}

resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "eks-igw"
  }
}

resource "aws_eip" "nat_eip" {
  vpc = true
}

resource "aws_nat_gateway" "eks_nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public_subnet[*].id, 0)

  tags = {
    Name = "eks-nat-gateway"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_subnet_route_table_association" {
  count          = var.public_subnet_count
  subnet_id      = element(aws_subnet.public_subnet[*].id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.eks_nat_gateway.id
  }

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "private_subnet_route_table_association" {
  count          = var.private_subnet_count
  subnet_id      = element(aws_subnet.private_subnet[*].id, count.index)
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_security_group" "eks_cluster_sg" {
  vpc_id = aws_vpc.eks_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-cluster-sg"
  }
}

resource "aws_security_group" "node_group_sg" {
  vpc_id = aws_vpc.eks_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-node-group-sg"
  }
}

resource "aws_ecr_repository" "hello_world_repo" {
  name = var.ecr_repo_name
}

resource "aws_iam_role" "eks_role" {
  name = var.eks_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_policy_attachment" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_eks_cluster" "new_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids         = aws_subnet.private_subnet[*].id
    security_group_ids = [aws_security_group.eks_cluster_sg.id]
  }
}

resource "aws_iam_role" "node_group_role" {
  name = var.node_group_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "node_group_policy_attachment" {
  role       = aws_iam_role.node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_group_policy_attachment_extra" {
  role       = aws_iam_role.node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_group_policy_attachment_extra_2" {
  role       = aws_iam_role.node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_eks_node_group" "worker_nodes" {
  cluster_name    = aws_eks_cluster.new_cluster.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.node_group_role.arn
  subnet_ids      = aws_subnet.private_subnet[*].id

  scaling_config {
    desired_size = var.node_group_desired_size
    max_size     = var.node_group_max_size
    min_size     = var.node_group_min_size
  }

  ami_type = "AL2_x86_64"

  tags = {
    Name = "eks-worker-nodes"
  }
}
