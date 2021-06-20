terraform {
	required_providers {
		vsphere = "~> 2.0"
	}
}
provider "vsphere" {
	vsphere_server		= "vcenter.lab01.one"
	user			= "administrator@vsphere.local"
	password		= "VMware1!SDDC"
	allow_unverified_ssl	= true
}

module "avi-controller" {
	source		= "./module-avi-controller"

	### vsphere variables
	datacenter	= "core"
	cluster		= "core"
	datastore	= "ds-esx11"
	host		= "esx11.lab01.one"
	network		= "vss-vmnet"

	### appliance variables
	vm_name		= "avic.lab01.one"
	remote_ovf_url	= "http://172.16.10.1:9000/iso/controller-20.1.6-9148.ova"
	mgmt-ip		= "172.16.10.119"
	mgmt-mask	= "255.255.255.0"
	default-gw	= "172.16.10.1"

	### initial config
	admin-password	= "VMware1!SDDC"
}
