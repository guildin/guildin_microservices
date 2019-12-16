resource "google_compute_instance" "docker-inst" {
  name         = "docker-inst-${count.index + 1}"
  count        = var.vmcount
  machine_type = "f1-micro"
  zone         = var.zone
  tags         = ["docker-machines"]
  boot_disk {
    initialize_params {
      image = var.docker-inst_disk_image
    }
  }
  network_interface {
    network = "default"
    access_config {

    }
  }
  metadata = {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }
}

