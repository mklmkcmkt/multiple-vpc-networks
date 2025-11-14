# This main.tf file contains all the resources (network, compute, and associated storage (boot disks) ) definitions that will be created
terraform {
    required_providers{
        google = {
            source = "hashicorp/google"
            version = "~> 7.0"
        }
        
    }

}
provider "google" {
    project = var.project_id
    region = var.region_us
}

# ---1. Creating 'mynetwork' Network (Auto-Mode) ---
resource "google_compute_network" "mynetwork" {
    name = "mynetwork"
    auto_create_subnetworks = true 
    routing_mode = "REGIONAL"

}

# # Since mynetwork is auto-mode, the subnets are created and named automatically.
# Since our vm-appliance is being built in the "us" region, 
# its NIC must connect to the mynetwork subnet that is also in a "us" region. 

data "google_compute_subnet" "mynetwork_us_subnet" {
    name = "mynetwork"
    region = var.region

# Explicitly depend on the network being created first
 depends_on = [google_compute_network.mynetwork]

}


resource "google_compute_firewall" "mynetwork_allow_combined" {
    name = "mynetwork-allow-icmp-ssh-rdp"
    network = google_compute_network.mynetwork.self_link

    #Allowing ICMP (ping)
    allow {
      protocol = "icmp"
    }

    #Allawing Trasmission Control Protocol (TCP) for both SSH (22) and RDP (3389)
    allow {
      protocol = "tcp"
      ports = ["22", "3389"]
    }

    source_ranges = ["0.0.0.0/0"]

}

# --- 2. Create 'managementnet' VPC and its resources ---

resource "google_compute_network" "management" {
    name = "management"
    auto_create_subnetworks = false
    routing_mode = "REGIONAL"

}

resource "google_compute_subnet" "managementsubnet_us" {
    name = "managementsubnet-us"
    ip_cidr_range = "10.130.0.0/20"
    region = var.region
    network = google_compute_network.management.id
}

resource "google_compute_firewall" "management_allow" {
    name = "management-allow-icmp-ssh-rdp"
    network = google_compute_network.management.self_link

    allow{
        protocol = "icpm"
    }

    allow{
        protocol = "tcp"
        ports = ["22", "3389"] # SSH and RDP
        
    }
    source_ranges = ["0.0.0.0/0"]

}

# --- 3. Create 'privatenet' VPC and its resources ---

resource "google_compute_network" "privatenet" {
    name = "privatenet"
    auto_create_subnetworks = false
    routing_mode = "REGIONAL"
    

}

resource "google_compute_subnet" "privatesubnet_us" {
    name = "privatesubnet-us"
    ip_cidr_range = "172.16.0.0/24"
    region = var.region
    network = google_compute_subnet.privatenet.id
}

resource "google_compute_subnet" "privatesubnet_eu" {
    name = "privatesubnet-eu"
    ip_cidr_range = "172.20.0.0/20"
    region = var.region_eu
    network = google_compute_network.privatenet.id
}

resource "google_compute_firewall" "privatenet_allow" {
    name = "privatenet-allow-icmp-ssh-rdp"
    network = google_compute_network.privatenet.self_link
    allow {
      protocol = "icmp"
    }

    allow {
      protocol = "tcp"
      ports = ["22", "3389"]
    }
    source_ranges = ["0.0.0.0/0"]
}

# --- 4. Create the Virtual Machines ---

resource "google_compute_instance" "mynet_us_vm" {
    name = "mynet-us-vm"
    machine_type = var.vm_machine_type
    zone = var.zone_us

    boot_disk {
        initialize_params {
            image = var.vm_os_image
        }
    }
    # Attach to the auto-mode 'mynetwork'.
  # We can specify the subnet directly using our data source.
  network_interface {
    subnetwork = data.google_compute_subnet.mynetwork_us_subnet.id

    
    access_config {
      // If empty, Google Cloud will then automatically assign an ephemeral external IP address to the VM from its available pool
    }

  }

  metadata = {
    "enable-oslogin" = "TRUE"
  }
    
}

resource "google_compute_instance" "mynet_eu_vm" {
    name = "mynet-eu-vm"
    machine_type = var.vm_machine_type
    zone = var.zone_eu

    boot_disk {
        initialize_params {
            image = var.vm_os_image
        }
    }

    # Attach to the auto-mode 'mynetwork'. We just specify the network, and GCP will  pick the auto-subnet in var.zone_eu's region.
    network_interface {
        network = google_compute_network.mynetwork.id
        access_config {
        // If empty, Google Cloud will then automatically assign an ephemeral external IP address to the VM from its available pool

        }
    }

    metadata = {
      "enable-oslogin" = "TRUE"
    }

}

resource "google_compute_instance" "management_us_vm" {
    name = "management-us-vm"
    machine_type = var.vm_machine_type
    zone = var.zone_us

    boot_disk {
        initialize_params {
            image = var.vm_os_image
        }
    }

    # Management is a Single NIC nic0 (ens4) VM
    network_interface {
      subnetwork = google_compute_subnet.managementsubnet_us.id
      access_config {
      // If empty, Google Cloud will then automatically assign an ephemeral external IP address to the VM from its available pool

      }
    }

    metadata = {
        enable-oslogin = "TRUE"
    }
    
}

resource "google_compute_instance" "privatenet_us_vm" {
  name         = "privatenet-us-vm"
  machine_type = var.vm_machine_type
  zone         = var.zone_us

  boot_disk {
    initialize_params {
      image = var.vm_os_image
    }
  }

  # This VM's single NIC nic0 (ens4) is in privatenet
  network_interface {
    subnetwork = google_compute_subnet.privatesubnet_us.id
    access_config {
      // Empty block requests an external IP
    }
  }

  metadata = {
    "enable-oslogin" = "TRUE"
  }
}

# --- 5. Create the Multi-NIC VM Appliance ---

resource "google_compute_instance" "vm_appliance" {
  name         = "vm-appliance"
  machine_type = var.vm_machine_type
  zone         = var.zone_us

  boot_disk {
    initialize_params {
      image = var.vm_os_image
    }
  }

  # nic0 (ens4) - Primary interface in 'privatenet'
  network_interface {
    subnetwork = google_compute_subnet.privatesubnet_us.id
    access_config {
      // Empty block requests an external IP
    }
  }

  # nic1 (ens5) - Secondary interface in 'managementnet'
  network_interface {
    subnetwork = google_compute_subnet.managementsubnet_us.id
  }

  # nic2 (ens6) - Secondary interface in 'mynetwork'
  network_interface {
    subnetwork = data.google_compute_subnet.mynetwork_us_subnet.id
  }

  metadata = {
    "enable-oslogin" = "TRUE"
  }

  # Allow the instance to forward packets (act as a gateway)
  can_ip_forward = true
}