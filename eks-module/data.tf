data "aws_eks_cluster" "cluster" {
  name = local.cluster_name

  depends_on = [aws_eks_cluster.k8scluster]
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.aws_eks_cluster.cluster.name
}

data "external" "oidc_thumbprint" {
  program = ["bash", "${path.module}/get_oidc_thumbprint.sh"]

  query = {
    oidc_url = aws_eks_cluster.k8scluster.identity[0].oidc[0].issuer
  }

  depends_on = [aws_eks_cluster.k8scluster]
}

