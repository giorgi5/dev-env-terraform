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
          Federated = "arn:aws:iam::058264300565:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/698E08BBE90E51A9DD67C515BF0A49A7"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "oidc.eks.us-east-1.amazonaws.com/id/698E08BBE90E51A9DD67C515BF0A49A7:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
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
