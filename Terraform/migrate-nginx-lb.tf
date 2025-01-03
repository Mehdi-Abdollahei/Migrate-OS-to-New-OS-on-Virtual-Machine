#------------------------------------- Connect to vSphere ----------------------------------------#

provider "vsphere" {
  user                 = "VCenter Username"
  password             = "Vcenter Password"
  vsphere_server       = "Vcenter URL"
  allow_unverified_ssl = true
}

#-------------------------------------------------------------------------------------------------#
#------------------------- Fetch Information About vSphere Environment ---------------------------#

data "vsphere_datacenter" "dc" {
  name = "Datacenter Name"
}

data "vsphere_datastore" "ds" {
  name          = "Data Store Name"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "existing_vm" {
  name          = var.existing_vm_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = "Template OS"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Data source to find the existing category
data "vsphere_tag_category" "backup_category" {
  name = "Backup"  # The name of your existing category
}

# Data source to find the existing tag
data "vsphere_tag" "backup_tag" {
  name        = var.new_vm_tags_for_backup
  category_id = data.vsphere_tag_category.backup_category.id
}

data "vsphere_host" "target_host" {
  name          = "specific HOST in your Vcenter"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Fetch the Distributed Switch (vDS) dynamically based on the existing VM's network
data "vsphere_distributed_virtual_switch" "vds" {
  name          =  "Distribute Switch Name"
  datacenter_id = data.vsphere_datacenter.dc.id

}

# Manually set the portgroup name for now
data "vsphere_network" "network" {
  name          = var.new_vm_vlan  # Set the name based on your vDS or network configuration
  datacenter_id = data.vsphere_datacenter.dc.id
}

#-------------------------------------------------------------------------------------------------#
#--------------------------------- Create New Virtual Machine ------------------------------------#

resource "vsphere_virtual_machine" "new_vm" {
  name             = "${data.vsphere_virtual_machine.existing_vm.name}-rhel"
  resource_pool_id = data.vsphere_host.target_host.resource_pool_id
  datastore_id     = data.vsphere_datastore.ds.id
  folder           = "Folder Path in vcenter - old vm"
  tags             = [data.vsphere_tag.backup_tag.id]
  guest_id         = "rhel7_64Guest"
  firmware         = "efi"
  dynamic "network_interface" {
    for_each = data.vsphere_virtual_machine.existing_vm.network_interfaces
    content {
      network_id   = data.vsphere_network.network.id
      adapter_type = "vmxnet3"
    }
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = var.new_os_hostname
        domain    = "test.net"
      }

      # Network Interface Configuration
      network_interface {
        ipv4_address = var.new_vm_ip
        ipv4_netmask = var.new_vm_netmask
      }

      # Set the Gateway (this goes outside the network_interface block)
      ipv4_gateway = var.new_vm_gateway
    }
  }

  # Set CPU and Memory Based on Existing VM
  num_cpus             = data.vsphere_virtual_machine.existing_vm.num_cpus
  num_cores_per_socket = data.vsphere_virtual_machine.existing_vm.num_cores_per_socket
  memory               = data.vsphere_virtual_machine.existing_vm.memory

  # Configure Disks for the New VM
  disk {
    label            = "disk00"
    size             = data.vsphere_virtual_machine.template.disks[0].size
    unit_number      = 0
    eagerly_scrub    = true
    thin_provisioned = false
  }

  disk {
    label            = "disk01"
    size             = data.vsphere_virtual_machine.template.disks[1].size
    unit_number      = 1
    eagerly_scrub    = true
    thin_provisioned = false
  }
}


#-------------------------------------------------------------------------------------------------#
# Null resource to power off the VM
# PowerOff old machine
resource "null_resource" "power_off_vm" {
  depends_on = [vsphere_virtual_machine.new_vm]

  provisioner "local-exec" {
    environment = {
      GOVC_URL      = "https://Vcenter URL/sdk"  # Replace with your vCenter URL
      GOVC_USERNAME = "Vcenter Username"
      GOVC_PASSWORD = "Vcenter Password"
      GOVC_INSECURE = "true"
    }

    command = <<EOT
    govc vm.power -off -force "${data.vsphere_virtual_machine.existing_vm.name}"
    EOT
  }
}
