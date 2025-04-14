data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  account = data.aws_caller_identity.current.account_id
}

resource "null_resource" "update_aws_auth6" {
  depends_on = [aws_eks_cluster.k8scluster]

  provisioner "local-exec" {
    command = <<-EOT
    sleep 60
    aws eks update-kubeconfig --name ${local.cluster_name} --region ${data.aws_region.current.name}
    kubectl patch configmap/aws-auth -n kube-system --patch "$(cat <<EOF
        data:
          mapRoles: |
            - groups:
              - system:bootstrappers
              - system:nodes
              rolearn: ${aws_iam_role.k8scluster_nodegroup_role.arn}
              username: system:node:{{EC2PrivateDNSName}}
            - groups:
              - system:masters
              rolearn: arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/OrganizationAccountAccessRole
              username: adminRoleUser
            - groups:
              - system:masters
              rolearn: ${var.gitHubActionsAppCIrole}
              username: GitHubActionsRoleUser
            - groups:
              - system:masters
              rolearn: ${var.gitHubActionsTerraformRole}
              username: GitHubActionsTerraformRoleUser
          mapUsers: |
            - userarn: arn:aws:iam::058264300565:user/admin
              username: admin
              groups:
                - system:masters
    EOF
    )"
    EOT
  }
  provisioner "local-exec" {
    when    = destroy
    command = "echo 'Destroy-time provisioner'"
  }
}
