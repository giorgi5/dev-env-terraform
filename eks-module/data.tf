data "aws_eks_cluster" "cluster" {
  name = "project-x-eks-dev"
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.aws_eks_cluster.cluster.name
}

data "aws_iam_openid_connect_provider" "oidc" {
  url = replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")
}