terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.20.0"
    }
  }
}

provider "google" {
  credentials = file("sincere-lexicon-417511-5fd3818c9699.json")
  project     = "sincere-lexicon-417511"
  region      = "us-east1"
}

resource "google_container_cluster" "primary" {
  name                     = "sincere-lexicon-417511-cluster"
  location                 = "us-east1"
  network                  = "default"
  initial_node_count       = 1
  remove_default_node_pool = true
}

resource "google_container_node_pool" "primary_nodes" {
  depends_on = [google_container_cluster.primary]
  name       = "sincere-lexicon-417511-node-pool"
  location   = "us-east1"
  cluster    = "sincere-lexicon-417511-cluster"
  node_count = 1

  node_config {
    disk_size_gb = 10
    disk_type    = "pd-standard"
    image_type   = "COS_CONTAINERD"
    machine_type = "e2-micro"
  }
}


