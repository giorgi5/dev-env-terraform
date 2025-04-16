data "aws_eks_cluster" "cluster" {
  name = local.cluster_name

  depends_on = [module.projectx-eks-cluster]
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.aws_eks_cluster.cluster.name
}

data "aws_iam_openid_connect_provider" "oidc" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}