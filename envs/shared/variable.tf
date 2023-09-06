variable "org_id" {
  description = "The GCP Org ID"
  type        = string
}

variable "project_id" {
  description = "The GCP Project ID"
  type        = string
}

variable "name" {
  description = "The GCP SA name"
  type        = string
}

variable "region" {
  description = "The GCP Region name"
  type        = string
}

variable "policies_folder" {
  type    = string
  default = "./policies"

}
