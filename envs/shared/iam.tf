resource "google_service_account" "function" {
  project    = var.project_id
  account_id = var.name
}

resource "google_service_account" "eventarc" {
  project    = var.project_id
  account_id = "cloud-custodian-eventarc"
}

resource "google_pubsub_topic_iam_member" "org_publisher" {
  topic  = google_pubsub_topic.pubsub_topic.id
  role   = "roles/pubsub.publisher"
  member = google_service_account.eventarc.member
}

resource "google_cloud_run_service_iam_member" "custodian_eventarc" {
  project  = data.google_cloud_run_service.this.project
  service  = data.google_cloud_run_service.this.name
  location = data.google_cloud_run_service.this.location
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.eventarc.email}"
}

resource "google_project_iam_member" "custodian_eventarc" {
  for_each = toset([
    "roles/cloudfunctions.viewer",
    "roles/eventarc.eventReceiver",
  ])

  project = var.project_id
  role    = each.value

  member = google_service_account.eventarc.member
}

# Required permissions but provided by gcp-org: https://github.com/InsigniaFinancial/gcp-org/blob/22d7d42f56d357aca5b3fced1c913a8a259adf46/envs/shared/iam.tf#L261C1-L269C2
# resource "google_organization_iam_member" "gcp_cloud_custodian" {
#   for_each = toset([
#     "roles/securitycenter.sourcesEditor",
#     "roles/securitycenter.findingsEditor",
#   ])
#   org_id = local.org_id
#   role   = each.key
#   member = "serviceAccount:gcp-cloud-custodian@prj-c-cloud-custodian-ct4g.iam.gserviceaccount.com"
# }
