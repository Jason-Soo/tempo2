terraform {
  required_version = ">= 1.3.6, <2.0"
  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.74"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}
