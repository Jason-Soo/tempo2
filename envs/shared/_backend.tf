terraform {
  backend "gcs" {
    bucket = "bkt-prj-b-seed-tfstate-35c0"
    prefix = "terraform/gcp-cloud-custodian/state"
  }
}
