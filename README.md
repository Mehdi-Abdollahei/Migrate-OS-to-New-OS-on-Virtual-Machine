# Migrate-OS-to-New-OS-on-Virtual-Machine
If you have concerns about upgrading an old operating system on a virtual machine or migrating an old operating system to another operating system, this project is tailored for you.
I have composed a set of Ansible playbooks and a Terraform configuration file that retrieves all your configurations to an Ansible server. Subsequently, Terraform is triggered to create a new virtual machine using a new operating system template. This template can be any operating system of your choice. At the conclusion, another group of Ansible playbooks will copy all your configurations to a virtual machine created by Terraform with the new operating system. (I would be delighted if you could offer feedback and assist in enhancing this project.)

STEP 1-4
* Retrieve all pertinent configuration settings from the previous machine (Zabbix Agent, keepalived, lsyncd, Nginx).

STEP 5
* Obtaining all requisite information for creating a new virtual machine in accordance with an existing virtual machine, including IP address, netmask, gateway, VLAN, hostname of the OS, and the desired name for the new virtual machine. This process creates a new virtual machine. (All of that information is obtained from the administrator using the AWX prompt survey.)

STEP 6
* Copy all configuration that fetched in step 1-4 (Zabbix Agent, keepalived, lsyncd, Nginx) to a new vm with a new os.


SETP 7
* Add iptables rule if you need

NOTICE: My Ansible version is 2.8.10, my AWX version is 15.0. My Terraform version is 1.9.8. It is possible that certain modules and plugins are compatible with this version.
-
Suggest: Certain tasks were written using the shell module. For instance, the iptables playbook utilizes the shell module, but I recommend utilizing the Ansible iptables module instead.
-
Suggest: To restart your service after copying configurations using Ansible, I recommend employing Ansible handlers and the notify mechanism.
-

![Migrate](https://github.com/user-attachments/assets/4511a6ac-11d1-4bb9-bbfc-d637e50242c2)


