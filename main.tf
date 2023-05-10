variable "project_id" {}
variable "region" {}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_composer_environment" "composer_env" {
  name    = "my-composer-env"
  region  = var.region
  project = var.project_id

  config {
    node_count = 3

    node_config {
      zone = "us-central1-a"
      machine_type = "n1-standard-1"
    }

    software_config {
      python_version = "3"
      airflow_config_overrides = {
        core-load_example = "True"
      }
    }
  }
}

resource "google_dataflow_job" "dataflow_job" {
  name = "dataflow-job"
  template_gcs_path = "gs://dataflow-templates/latest/Word_Count"
  temp_gcs_location = "gs://dataflow-temp"
  parameters = {
    inputFile = "gs://dataflow-samples/shakespeare/kinglear.txt"
    output = "gs://<your-bucket>/counts"
  }
  project = var.project_id
  region  = var.region
  on_delete = "cancel"
}

resource "google_bigquery_dataset" "bigquery_dataset" {
  dataset_id  = "my_dataset"
  project     = var.project_id
  location    = "US"
}

resource "google_storage_bucket" "bucket" {
  name     = "my-bucket"
  location = var.region
  project  = var.project_id
}
