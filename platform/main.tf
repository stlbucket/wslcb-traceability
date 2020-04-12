provider "google" {
  credentials = file("~/lcb-key.json")
  project     = "lcb-1122"
  region      = "us-central1"
  zone        = "us-central1-a"
}

locals {
  project_id     = "lcb-1122"
  location_id = "us-central"
}

# module "app-engine"  {
#   source = "./modules/app-engine"
#   project_id = local.project_id
#   location_id = local.location_id
# }

module "ui"  {
  source  = "./modules/ui"
  # bucket_name = "lcb.fn-bucket.org"
}

module "db"  {
  source  = "./modules/db"
}

