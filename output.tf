output "mynet_us_vm_ips" {
  description = "IP addresses for mynet-us-vm"
  value = {
    internal_ip = google_compute_instance.mynet_us_vm.network_interface[0].network_ip
    external_ip = google_compute_instance.mynet_us_vm.network_interface[0].access_config[0].nat_ip
  }
}

output "mynet_eu_vm_ips" {
  description = "IP addresses for mynet-eu-vm"
  value = {
    internal_ip = google_compute_instance.mynet_eu_vm.network_interface[0].network_ip
    external_ip = google_compute_instance.mynet_eu_vm.network_interface[0].access_config[0].nat_ip
  }
}

output "management_us_vm_ips" {
  description = "IP addresses for management-us-vm"
  value = {
    internal_ip = google_compute_instance.management_us_vm.network_interface[0].network_ip
    external_ip = google_compute_instance.management_us_vm.network_interface[0].access_config[0].nat_ip
  }
}

output "privatenet_us_vm_ips" {
  description = "IP addresses for privatenet-us-vm"
  value = {
    internal_ip = google_compute_instance.privatenet_us_vm.network_interface[0].network_ip
    external_ip = google_compute_instance.privatenet_us_vm.network_interface[0].access_config[0].nat_ip
  }
}

output "vm_appliance_external_ip" {
  description = "The external IP of the appliance (on its primary NIC)"
  value       = google_compute_instance.vm_appliance.network_interface[0].access_config[0].nat_ip
}

output "vm_appliance_internal_ips" {
  description = "All internal IP addresses for the multi-NIC vm-appliance"
  value = {
    nic0_privatenet_ip    = google_compute_instance.vm_appliance.network_interface[0].network_ip
    nic1_managementnet_ip = google_compute_instance.vm_appliance.network_interface[1].network_ip
    nic2_mynetwork_ip     = google_compute_instance.vm_appliance.network_interface[2].network_ip
  }
}