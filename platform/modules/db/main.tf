
locals {
}

data "google_compute_network" "default" {
  name = "default"
}

resource "google_sql_database_instance" "db_dev" {
  # name             = "${var.project_id}-pg-db-${formatdate("YYMMDDhhmm", timestamp())}"
  name             = "${var.project_id}-pg-db-dev"
  database_version = "POSTGRES_11"
  region = "us-central1"

  # depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier = "db-f1-micro"  // db-g1-small   ---   gcloud sql tiers list
    ip_configuration {
      ipv4_enabled    = false
      # private_network = var.private_network.self_link
      private_network = data.google_compute_network.default.self_link
    }
  }
}

resource "google_sql_user" "db_user" {
  name     = "postgres"
  instance = google_sql_database_instance.db_dev.name
  password = "tacos"
}


# resource "google_secret_manager_secret" "postgres-pwd" {s
#   provider = google-beta

#   secret_id = "postgres-pwd"

#   replication {
#     automatic = true
#   }
# }


# resource "google_secret_manager_secret_version" "secret-version-basic" {
#   provider = google-beta

#   secret = google_secret_manager_secret.postgres-pwd.id

#   secret_data = "tacos"
# }
