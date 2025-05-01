provider "google" {
  project = "<project-ID>"
  region  = "us-central1"
  zone    = "us-central1-c"
}

resource "google_compute_network" "vpc_network" {
  name                    = "my-vpc-network"
  auto_create_subnetworks = true
}

resource "google_compute_instance" "default" {
  name         = "simple-vm"
  machine_type = "f1-micro"
  zone         = "us-west1-a"

  tags = ["ssh"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  metadata_startup_script = <<-EOT
    sudo apt-get update
    sudo apt-get install -yq build-essential
  EOT

  network_interface {
    network = google_compute_network.vpc_network.id
    access_config {}  
  }
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "java" {
  name    = "java-app-firewall"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }
  source_ranges = ["0.0.0.0/0"]
}

output "instance_ip" {
  value = google_compute_instance.default.network_interface.0.access_config.0.nat_ip
}
