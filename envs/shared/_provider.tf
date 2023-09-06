provider "google" {
  impersonate_service_account = "sa-terraform-cloud-custodian@prj-b-seed-2510.iam.gserviceaccount.com"
  region                      = var.region
}
