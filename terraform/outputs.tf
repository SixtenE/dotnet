output "service_url" {
  description = "Public URL of the deployed Cloud Run service."
  value       = google_cloud_run_v2_service.my_dotnet_api.uri
}

output "artifact_registry_url" {
  description = "Base Artifact Registry Docker URL for pushed images."
  value       = format("%s-docker.pkg.dev/%s/%s", var.region, var.project_id, google_artifact_registry_repository.my_api.repository_id)
}
