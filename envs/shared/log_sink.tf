resource "google_pubsub_topic" "pubsub_topic" {
  name    = "custodian-pubsub-${random_string.suffix.result}"
  project = var.project_id
}

resource "google_logging_organization_sink" "custodian_sink" {
  org_id           = var.org_id
  name             = "custodian-org-sink"
  include_children = true

  destination = "pubsub.googleapis.com/${google_pubsub_topic.pubsub_topic.id}"
  filter      = <<EOS
log_id("cloudaudit.googleapis.com/activity")
AND NOT resource.type="organization"
AND (protoPayload.methodName="setIamPolicy")
EOS
}
