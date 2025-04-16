resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name    = aws_eks_cluster.k8scluster.name
  addon_name      = "aws-ebs-csi-driver"
  addon_version   = "v1.41.0-eksbuild.1"  # Ensure this is the latest version
  service_account_role_arn = aws_iam_role.ebs_csi_driver_role.arn

}

resource "aws_iam_role" "ebs_csi_driver_role" {
  name = "AmazonEKS_EBS_CSI_DriverRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.oidc.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })
}


resource "aws_iam_policy_attachment" "ebs_csi_driver_policy_attachment" {
  name       = "ebs-csi-driver-policy-attachment"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  roles      = [aws_iam_role.ebs_csi_driver_role.name]
}
