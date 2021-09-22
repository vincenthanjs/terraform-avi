terraform {
	required_providers {
		vsphere = "~> 2.0"
	}
}
provider "vsphere" {
	vsphere_server		= "192.168.1.142"
	user			= "administrator@vsphere.local"
	password		= "VMware1"
	allow_unverified_ssl	= true
}

module "avi-controller" {
	source		= "./module-avi-controller"

	### vsphere variables
	datacenter	= "SUN01"
	cluster		= "CL01-MGMT"
	datastore	= "vsanDatastore"
	host		= "192.168.1.201"
	network		= "VDS01-VLAN115-IaaS"

	### appliance variables
	vm_name		= "sun05-avicontroller02-01"
	remote_ovf_url	= "http://172.16.10.1:9000/iso/controller-20.1.6-9132.ova"
	mgmt-ip		= "10.115.1.41"
	mgmt-mask	= "255.255.255.0"
	default-gw	= "10.115.1.1"

	### initial config
	admin-password	= "VMware1"
}
