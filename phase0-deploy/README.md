## [`terraform-avi`](../README.md)`/phase0-deploy`
Terraform module for the `avi networks` load-balancing platform  
Clone repository and adjust `main.tf` as required  

---

#### `run`
```
terraform init
terraform plan
terraform apply
```

**Note: After completing this `plan` you must login and complete the one-time welcome setup workflow**

#### `destroy` [optional]
```
terraform destroy
```

---

#### `main.tf`
```
terraform {
	required_providers {
		vsphere = "~> 1.26.0"
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
	datacenter	= "lab01"
	cluster		= "mgmt"
	datastore	= "ds-esx15.lab01.one"
	host		= "esx15.lab01.one"
	network		= "pg-mgmt"

	### appliance variables
	vm_name		= "avic.lab01.one"
	remote_ovf_url	= "http://172.16.10.1:9000/iso/controller-20.1.5-9148.ova"
	mgmt-ip		= "172.16.10.119"
	mgmt-mask	= "255.255.255.0"
	default-gw	= "172.16.10.1"

	### initial config - will replace default password
	admin-password	= "VMware1!SDDC"
}
```
