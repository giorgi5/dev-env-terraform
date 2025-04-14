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
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "ebs_csi_driver_policy_attachment" {
  name       = "ebs-csi-driver-policy-attachment"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  roles      = [aws_iam_role.ebs_csi_driver_role.name]
}
