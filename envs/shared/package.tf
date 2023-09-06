resource "random_string" "suffix" {
  length  = 4
  upper   = false
  special = false
}

resource "local_file" "convert_json" {
  filename = "${local.folder_name}/config.json"
  content  = jsonencode(yamldecode(local.policy_file))
}

# Create a data archive file for each policy
data "archive_file" "policy_archive" {
  source_dir  = local.folder_name
  output_path = "${path.module}/src.zip"
  type        = "zip"
  depends_on = [
    local_file.convert_json
  ]
}

# Create a Cloud Storage bucket to store the function source code zip file
resource "google_storage_bucket" "cloud_custodian_bucket" {
  name                        = "bkt-prj-c-custodian-${random_string.suffix.result}"
  location                    = var.region
  force_destroy               = true # Delete the bucket even if it has content
  uniform_bucket_level_access = true
  project                     = var.project_id
}

# Upload the archive file to the bucket
resource "google_storage_bucket_object" "function_zip" {
  name   = "custodian-${random_string.suffix.result}.${data.archive_file.policy_archive.output_md5}"
  bucket = google_storage_bucket.cloud_custodian_bucket.name
  source = data.archive_file.policy_archive.output_path
}
