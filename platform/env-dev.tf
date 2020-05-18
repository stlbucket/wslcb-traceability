module "db-dev" {
  source  = "./modules/db"
  # private_network = module.vpc.private_network
  project_id = local.project_id
  env = "dev"
}
