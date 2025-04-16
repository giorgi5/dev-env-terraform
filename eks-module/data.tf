data "aws_eks_cluster" "cluster" {
  name = local.cluster_name

  depends_on = [aws_eks_cluster.k8scluster]
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.aws_eks_cluster.cluster.name
}

data "aws_iam_openid_connect_provider" "oidc" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer

  depends_on = [aws_eks_cluster.k8scluster]
}

data "external" "oidc_thumbprint" {
  program = ["bash", "${path.module}/get_oidc_thumbprint.sh"]

  query = {
    oidc_url = aws_eks_cluster.k8scluster.identity[0].oidc[0].issuer
  }

  depends_on = [aws_eks_cluster.k8scluster]
}
