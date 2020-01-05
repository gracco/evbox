provider "google" {
  project = var.project_name
  region  = var.project_region
  zone    = var.project_zone
}

resource "google_compute_instance" "default" {
  name         = var.instance_name
  machine_type = var.machine_type

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

}

resource "google_compute_firewall" "default" {
 name    = "nginx-firewall"
 network = "default"

 allow {
   protocol = "tcp"
   ports    = ["443"]
 }
}