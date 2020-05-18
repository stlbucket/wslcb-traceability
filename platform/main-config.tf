provider "google" {
  credentials = file("~/.keys/sa-traceability-277402-key.json")
  project     = "traceability-277402"
  region      = "us-central1"
  zone        = "us-central1-a"
}

locals {
  project_id     = "traceability-277402"
  location_id = "us-central"
}


# module "ctl-vm"  {
#   source  = "./modules/ctl-vm"
#   # private_network = module.vpc.private_network
#   project_id = local.project_id
# }

# module "vpc"  {
#   source = "./modules/vpc"
#   project_id = local.project_id
# }

# module "firewall"  {
#   source = "./modules/firewall"
#   private_network = module.vpc.private_network
#   project_id = local.project_id
# }
