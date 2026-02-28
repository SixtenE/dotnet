#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   PROJECT_ID=ws-cicd \
#   DEPLOYER_SA=gcloud-action@ws-cicd.iam.gserviceaccount.com \
#   RUNTIME_SA=myapi-runtime@ws-cicd.iam.gserviceaccount.com \
#   ./scripts/fix-gcp-cloud-run-iam.sh
#
# Prereq: run as a principal that can change IAM policy bindings.

PROJECT_ID="${PROJECT_ID:-ws-cicd}"
DEPLOYER_SA="${DEPLOYER_SA:-gcloud-action@ws-cicd.iam.gserviceaccount.com}"
RUNTIME_SA="${RUNTIME_SA:-myapi-runtime@ws-cicd.iam.gserviceaccount.com}"

echo "Project: ${PROJECT_ID}"
echo "Deployer SA: ${DEPLOYER_SA}"
echo "Runtime SA: ${RUNTIME_SA}"

PROJECT_NUMBER="$(gcloud projects describe "${PROJECT_ID}" --format='value(projectNumber)')"
if [[ -z "${PROJECT_NUMBER}" ]]; then
  echo "Could not resolve project number for ${PROJECT_ID}" >&2
  exit 1
fi

CLOUDBUILD_DEFAULT_SA="${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"
COMPUTE_DEFAULT_SA="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"

grant_project_role() {
  local member="$1"
  local role="$2"
  echo "Granting ${role} to ${member} on project ${PROJECT_ID}"
  gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="${member}" \
    --role="${role}" \
    --quiet >/dev/null
}

grant_sa_role() {
  local target_sa="$1"
  local member="$2"
  local role="$3"
  echo "Granting ${role} on ${target_sa} to ${member}"
  gcloud iam service-accounts add-iam-policy-binding "${target_sa}" \
    --member="${member}" \
    --role="${role}" \
    --project="${PROJECT_ID}" \
    --quiet >/dev/null
}

sa_exists() {
  local sa="$1"
  gcloud iam service-accounts describe "${sa}" \
    --project="${PROJECT_ID}" \
    --format='value(email)' >/dev/null 2>&1
}

# 1) Roles needed by the GitHub deployer identity.
grant_project_role "serviceAccount:${DEPLOYER_SA}" "roles/run.admin"
grant_project_role "serviceAccount:${DEPLOYER_SA}" "roles/serviceusage.serviceUsageConsumer"
grant_project_role "serviceAccount:${DEPLOYER_SA}" "roles/storage.admin"

# Allow deployer to use the Cloud Run runtime service account (--service-account).
grant_sa_role "${RUNTIME_SA}" "serviceAccount:${DEPLOYER_SA}" "roles/iam.serviceAccountUser"

# 2) Roles needed by Cloud Build default service account(s).
# Newer projects may use cloudbuild SA; some environments still use compute SA.
for BUILD_SA in "${CLOUDBUILD_DEFAULT_SA}" "${COMPUTE_DEFAULT_SA}"; do
  if sa_exists "${BUILD_SA}"; then
    echo "Applying build roles to ${BUILD_SA}"
    grant_project_role "serviceAccount:${BUILD_SA}" "roles/run.builder"
    grant_project_role "serviceAccount:${BUILD_SA}" "roles/artifactregistry.writer"
  else
    echo "Skipping ${BUILD_SA} (service account does not exist in ${PROJECT_ID})"
  fi
done

echo "Done. IAM changes can take a few minutes to propagate."
