variable "existing_vm_name" {
  description = "Please Enter Your Exist VM Name For Migration To RedHat: "
  type        = string
}

variable "new_os_hostname" {
  description = "Please Enter Your Hostname Base oN Exist VM (Example OS Hostname): "
  type        = string
}

variable "new_vm_ip" {
  description = "Please Enter Your IP Address Base On Exist Machine: "
  type        = string
}

variable "new_vm_netmask" {
  description = "Please Enter Your Netmask Base On Exist Machine (For example 24): "
  type        = string
}

variable "new_vm_gateway" {
  description = "Please Enter Your Gateway Base On Exist Machine: "
  type        = string
}

variable "new_vm_tags_for_backup" {
  description = "Please Enter appropriate tag for Backup (Example Tag Name): "
  type        = string
}

variable "new_vm_vlan" {
  description = "Please Enter Your VLAN Base On Exist Machine (Example Vlan Name'): "
  type        = string
}
