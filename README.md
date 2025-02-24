# google-cloud-deploy


# Criação da rede VPC
resource "google_compute_network" "vpc_network" {
  name                    = "my-vpc-network"
  auto_create_subnetworks = true
}

# Criação de uma máquina virtual
resource "google_compute_instance" "default" {
  name         = "simple-vm"
  machine_type = "f1-micro"  # Tipo de máquina mais barato
  zone         = "us-west1-a"  # Região e zona onde a VM será criada

  tags = ["ssh"]  # Adiciona a tag "ssh" para ativar a regra de firewall

  # Configuração do disco de inicialização
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"  # Imagem Debian 11
    }
  }

  # Script de inicialização (opcional)
  metadata_startup_script = <<-EOT
    sudo apt-get update
    sudo apt-get install -yq build-essential
  EOT

  # Configuração de rede
  network_interface {
    network = google_compute_network.vpc_network.id
    access_config {}  # Garante IP público para acesso SSH
  }
}

# Regra de firewall para permitir SSH (porta 22)
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]  # Permite acesso de qualquer IP
}

resource "google_compute_firewall" "java" {
 name = "java-app-firewall"
 network = google_compute_network.vpc_network.id
 allow {
 protocol = "tcp"
 ports = ["8080"]
 }
 source_ranges = ["0.0.0.0/0"]
}

# Exibe o IP público da VM
output "instance_ip" {
  value = google_compute_instance.default.network_interface.0.access_config.0.nat_ip
}
