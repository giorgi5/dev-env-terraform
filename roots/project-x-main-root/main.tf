module "projectx-eks-cluster" {
  source                     = "../../eks-module"
  vpc_id                     = var.vpc_id
  subnet_ids                 = var.subnet_ids
  cluster_version            = var.cluster_version
  services_cidr              = var.services_cidr
  stage                      = var.stage
  project                    = var.project
  workers_desired            = var.workers_desired
  workers_max                = var.workers_max
  workers_min                = var.workers_min
  workers_pricing_type       = var.workers_pricing_type
  instance_types             = var.instance_types
  gitHubActionsAppCIrole     = var.gitHubActionsAppCIrole
  gitHubActionsTerraformRole = var.gitHubActionsTerraformRole
}

# resource "terraform_data" "example2" {
#   provisioner "local-exec" {
#     command = "sleep 30"
#   }
# }
