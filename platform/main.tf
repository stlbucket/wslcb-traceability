module "ctl-vm"  {
  source  = "./modules/ctl-vm"
  # private_network = module.vpc.private_network
  project_id = local.project_id
}

# module "vpc"  {
#   source = "./modules/vpc"
#   project_id = local.project_id
# }

# module "firewall"  {
#   source = "./modules/firewall"
#   private_network = module.vpc.private_network
#   project_id = local.project_id
# }
