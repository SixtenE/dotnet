variable "project_id" {
  description = "GCP project ID where resources will be created."
  type        = string
}

variable "region" {
  description = "GCP region for Cloud Run and Artifact Registry."
  type        = string
  default     = "europe-west1"
}

variable "image" {
  description = "Container image URI (including tag) to deploy to Cloud Run."
  type        = string
}
