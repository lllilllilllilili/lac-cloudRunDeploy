# Filename: main.tf
# Configure GCP project
provider "google" {
  project = "jungang-poc"
}
# Deploy image to Cloud Run
resource "google_cloud_run_service" "myphpapp" {
  name     = "myphpapp"
  location = "asia-northeast3"
  template {
    spec {
      containers {
        image = "gcr.io/jungang-poc/hello-php"
      }
    }
  }
  traffic {
    percent         = 100
    latest_revision = true
  }
}
# Create public access
data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}
# Enable public access on Cloud Run service
resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.myphpapp.location
  project     = google_cloud_run_service.myphpapp.project
  service     = google_cloud_run_service.myphpapp.name
  policy_data = data.google_iam_policy.noauth.policy_data
}
# Return service URL
output "url" {
  value = "${google_cloud_run_service.myphpapp.status[0].url}"
}