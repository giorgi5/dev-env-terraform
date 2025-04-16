resource "aws_eks_cluster" "k8scluster" {
  name     = local.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.k8sclusterrole.arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  kubernetes_network_config {
    service_ipv4_cidr = var.services_cidr
  }

  depends_on = [
    aws_iam_role_policy_attachment.k8sclusterrole-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.k8sclusterrole-AmazonEKSVPCResourceController,
  ]

  tags = {
    Name  = local.cluster_name
    Owner = local.owner_tag
  }
}

output "cluster_name" {
  value = aws_eks_cluster.k8scluster.name
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "k8sclusterrole" {
  name               = "${local.cluster_name}-iam-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "k8sclusterrole-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.k8sclusterrole.name
}

resource "aws_iam_role_policy_attachment" "k8sclusterrole-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.k8sclusterrole.name
}

resource "aws_security_group" "k8scluster-sg" {
  name        = "eks-cluster-sg-${local.cluster_name}"
  description = "Main Security Group of EKS cluster"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow All Self"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
    # "aws:eks:cluster-name"                        = local.cluster_name
    "Name" = "eks-cluster-sg-${local.cluster_name}"
  }
}

# Dynamically create the OIDC provider
resource "aws_iam_openid_connect_provider" "oidc_provider" {
  url = aws_eks_cluster.k8scluster.identity[0].oidc[0].issuer

  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [data.external.oidc_thumbprint.result["thumbprint"]]

  depends_on = [aws_eks_cluster.k8scluster]
}
