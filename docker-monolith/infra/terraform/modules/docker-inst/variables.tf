variable zone {
  description = "zone to deploy in"
  default     = "europe-west1-b"
}
variable public_key_path {
  description = "Path to the public key used for ssh access"
}
variable private_key_path {
  description = "IKE credential placement"
  default     = "~/.ssh/appuser"
}
variable docker-inst_disk_image {
  description = "Disk image"
  default     = "base-dm"
}

variable vmcount {
  description = "Number of instances"
  default     = "2"
}
