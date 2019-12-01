variable project {
  description = "Project ID"
}
variable region {
  description = "Region"
  default     = "europe-west1"
}
variable public_key_path {
  description = "Path to the public key used for ssh access"
}
variable disk_image {
  description = "Disk image"
}
variable private_key_path {
  description = "Path to the private key used for ssh access"
}
variable zone {
  description = "zone to deploy in"
  default     = "europe-west1-b"
}
variable vmcount {
  description = "Number of instances"
  default     = "1"
}

variable docker-inst_disk_image {
  description = "Disk image for reddit db"
  default     = "base-dm"
}
