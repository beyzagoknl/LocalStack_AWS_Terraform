output "vpc_id" {
  value = aws_vpc.eks_vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnet[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnet[*].id
}

output "eks_cluster_name" {
  value = aws_eks_cluster.new_cluster.name
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.new_cluster.endpoint
}

output "eks_cluster_security_group_id" {
  value = aws_security_group.eks_cluster_sg.id
}

output "node_group_role_arn" {
  value = aws_iam_role.node_group_role.arn
}
