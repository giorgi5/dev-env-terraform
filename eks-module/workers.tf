resource "aws_eks_node_group" "k8scluster_nodegroup" {
  cluster_name    = aws_eks_cluster.k8scluster.name
  node_group_name = "${local.cluster_name}-nodegroup"
  node_role_arn   = aws_iam_role.k8scluster_nodegroup_role.arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = var.workers_desired
    max_size     = var.workers_max
    min_size     = var.workers_min
  }

  update_config {
    max_unavailable = 1
  }
  capacity_type  = var.workers_pricing_type
  instance_types = var.instance_types

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.k8scluster_nodegroup-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.k8scluster_nodegroup-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.k8scluster_nodegroup-AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_iam_role" "k8scluster_nodegroup_role" {
  name = "${local.cluster_name}-nodegroup-iam-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "k8scluster_nodegroup-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.k8scluster_nodegroup_role.name
}

resource "aws_iam_role_policy_attachment" "k8scluster_nodegroup-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.k8scluster_nodegroup_role.name
}

resource "aws_iam_role_policy_attachment" "k8scluster_nodegroup-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.k8scluster_nodegroup_role.name
}
