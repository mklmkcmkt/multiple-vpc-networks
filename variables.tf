variable "project_id" {
    type = string
    description = "The ID of the GC project to deploy resources into"

}

variable "region_us" {
    type = string
    description = "The geography region us region "
    default = "us-central1"


}

variable "zone_us" {
    type = string
    description = "The zone to host the us VMs/resources"
}

variable "region_eu" {
  type        = string
  description = "The 'eu' region."
  default     = "europe-west1"
}

variable "zone_eu" {
  type        = string
  description = "The 'eu' zone."
  default     = "europe-west1-b"
}

variable "vm_machine_type" {
    type = string
    description = "The VMs machine types"
    default     = "e2-medium"
}

variable "vm_os_image" {
    type = string
    description = "The boot image for the VMs"
    default = "debian-cloud/debian-12"
}