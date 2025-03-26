# return current region details
data "aws_region" "current" {}

# return current user details along with account details
data "aws_caller_identity" "current" {}

# current account number
locals {
  account = data.aws_caller_identity.current.account_id
}

# Update aws-auth configmap, to ensure additional role is added for Access Management in the K8s cluster
# Terraform does not re-apply if command changes, therefore update null_resource name to force terraform to re-run this local exec
resource "null_resource" "update_aws_auth5" {
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
    EOF
    )"
    EOT
  }
  provisioner "local-exec" {
    when    = destroy
    command = "echo 'Destroy-time provisioner'"
  }
}
