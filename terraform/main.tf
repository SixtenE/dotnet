terraform {
  required_version = ">= 1.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  backend "gcs" {}
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Resolve project metadata so we can derive the default compute service account.
data "google_project" "current" {
  project_id = var.project_id
}

# Enable all required Google Cloud APIs before creating dependent resources.
resource "google_project_service" "required_apis" {
  for_each = toset([
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "iam.googleapis.com",
    "secretmanager.googleapis.com"
  ])

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

# Create the Artifact Registry Docker repository used to store API images.
resource "google_artifact_registry_repository" "my_api" {
  project       = var.project_id
  location      = var.region
  repository_id = "my-api"
  description   = "Docker repository for my-dotnet-api images"
  format        = "DOCKER"

  depends_on = [google_project_service.required_apis]
}

# Create the secret container (without versions) for DB connection strings.
resource "google_secret_manager_secret" "db_connection_string" {
  project   = var.project_id
  secret_id = "db-connection-string"

  replication {
    auto {}
  }

  depends_on = [google_project_service.required_apis]
}

# Deploy the Cloud Run service with autoscaling, resource limits, and secret-based env var.
resource "google_cloud_run_v2_service" "my_dotnet_api" {
  project  = var.project_id
  name     = "my-dotnet-api"
  location = var.region

  template {
    scaling {
      min_instance_count = 0
      max_instance_count = 3
    }

    containers {
      image = var.image

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }

      ports {
        container_port = 8080
      }

      env {
        name = "ConnectionStrings__Default"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.db_connection_string.secret_id
            version = "latest"
          }
        }
      }
    }
  }

  depends_on = [
    google_artifact_registry_repository.my_api,
    google_secret_manager_secret.db_connection_string
  ]
}

# Grant Cloud Run's default compute service account access to read the secret.
resource "google_secret_manager_secret_iam_member" "cloud_run_secret_accessor" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.db_connection_string.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${data.google_project.current.number}-compute@developer.gserviceaccount.com"
}

# Allow unauthenticated invocations so the API is publicly reachable.
resource "google_cloud_run_v2_service_iam_member" "public_invoker" {
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.my_dotnet_api.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
