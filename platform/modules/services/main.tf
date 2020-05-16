resource "google_project_service" "cloudapis" {
  service = "cloudapis.googleapis.com"
}
resource "google_project_service" "servicenetworking" {
  service = "servicenetworking.googleapis.com"
}
resource "google_project_service" "sql-component" {
  service = "sql-component.googleapis.com"
}
resource "google_project_service" "sqladmin" {
  service = "sqladmin.googleapis.com"
}
resource "google_project_service" "secretmanager" {
  service = "secretmanager.googleapis.com"
}
resource "google_project_service" "vpcaccess" {
  service = "vpcaccess.googleapis.com"
}
