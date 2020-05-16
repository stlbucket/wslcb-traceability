
locals {
}

# commented stuff is an attempt to make access private on default network.
# this throws an error, which is not fixed by this solution, which is the most promising i have found:
# https://stackoverflow.com/questions/54865411/terraform-creating-google-cloud-sql-instance-not-working

# data "google_compute_network" "default" {
#   name = "default"
# }

resource "google_sql_database_instance" "db_dev" {
  name             = "${var.project_id}-pg-db-${formatdate("YYMMDDhhmm", timestamp())}"
  # name             = "${var.project_id}-pg-db-dev"
  database_version = "POSTGRES_11"
  region = "us-central1"

  # depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier = "db-f1-micro"  // db-g1-small   ---   gcloud sql tiers list
    ip_configuration {
      ipv4_enabled    = true

      # ipv4_enabled    = false
      # pick one - var.private_network means you have to uncomment other files and use vpc in top level main.tf
      # private_network = data.google_compute_network.default.self_link
      # private_network = var.private_network.self_link
    }
  }
}

# resource "random_password" "password_dev" {
#   length = 16
# }


resource "google_sql_user" "db_user_dev" {
  name     = "postgres"
  instance = google_sql_database_instance.db_dev.name
  # password = random_password.password_dev.result
  password = "tacos"
}

# gcloud auth application-default login 
resource "google_secret_manager_secret" "postgres_pwd" {
  provider = google-beta
  project = var.project_id

  secret_id = "pg_pwd_dev"

  labels = {
    label = "pg_pwd_dev"
  }

  replication {
    automatic = true
  }
}


resource "google_secret_manager_secret_version" "postgres_pwd_version" {
  provider = google-beta

  secret = google_secret_manager_secret.postgres_pwd.id

  secret_data = "tacos"
}
