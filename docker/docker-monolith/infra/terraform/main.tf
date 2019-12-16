
provider "google" {
  version = "2.15"
  project = var.project
  region  = var.region
}

module "docker-inst" {
  source                 = "./modules/docker-inst"
  public_key_path        = var.public_key_path
  zone                   = var.zone
  docker-inst_disk_image = var.docker-inst_disk_image
}

module "vpc" {
  source        = "./modules/vpc"
  source_ranges = ["0.0.0.0/0"]
}
