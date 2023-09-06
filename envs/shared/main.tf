locals {
  folder_name     = "../../src"
  policies_folder = "./policies"
  policy_file     = file("./policies/custodian-policy.yaml")
}

# Create a Cloud Function from the uploaded zip file
resource "google_cloudfunctions2_function" "function" {
  location = var.region

  project     = var.project_id
  name        = "custodian-monitoring"
  description = "Cloud Custodian Monitoring"

  build_config {
    runtime     = "python311"
    entry_point = "run"

    source {
      storage_source {
        bucket = google_storage_bucket_object.function_zip.bucket
        object = google_storage_bucket_object.function_zip.name
      }
    }
  }

  service_config {
    available_memory   = "512Mi"
    max_instance_count = 10
    ingress_settings   = "ALLOW_INTERNAL_ONLY"

    environment_variables = {
      GOOGLE_CLOUD_PROJECT = var.project_id
    }

    service_account_email = google_service_account.function.email
  }

  event_trigger {
    trigger_region        = var.region
    event_type            = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic          = google_pubsub_topic.pubsub_topic.id
    service_account_email = google_service_account.eventarc.email
  }
}

data "google_cloud_run_service" "this" {
  project  = google_cloudfunctions2_function.function.project
  name     = google_cloudfunctions2_function.function.name
  location = google_cloudfunctions2_function.function.location
}
