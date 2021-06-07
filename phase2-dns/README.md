## [`terraform-avi`](../README.md)`/phase2-dns`
Terraform module for the `avi networks` load-balancing platform  
Clone repository and adjust `terraform.tfvars` and `main.tf` as required  

---

#### `run`
```
terraform init
terraform plan
terraform apply
```

**Note: After completing this `plan` you must login and enable `Administration > Settings > DNS Service`**

#### `destroy` [optional]
```
terraform destroy
```

---

#### `terraform.tfvars`
```
# avi parameters
avi_server	= "avic.lab01.one"
avi_username	= "admin"
avi_password	= "VMware1!SDDC"
avi_version	= "20.1.5"

# dns service
cloud_name	= "tf-vmware-cloud"
vs_name		= "ns1"
vs_fqdn		= "ns1.lb.lab01.one"
vs_address	= "172.16.10.120"
```

#### `main.tf`
```
## provider setup
terraform {                                                                        
	required_providers {
		avi = {
			source  = "vmware/avi"
			version = ">= 20.1.5"
		}
	}
}
provider "avi" {
	avi_controller		= var.avi_server
	avi_username		= var.avi_username
	avi_password		= var.avi_password
	avi_tenant		= "admin"
	avi_version		= "20.1.5"
}

## avi data objects
data "avi_tenant" "admin" {
	name	= "admin"
}
data "avi_cloud" "vmware" {
	name	= var.cloud_name
}
data "avi_cloud" "default" {
	name	= "Default-Cloud"
}
data "avi_serviceenginegroup" "mgmt" {
	name	= "mgmt-se-group"
}
data "avi_applicationprofile" "system-dns" {
	name	= "System-DNS"
}
data "avi_networkprofile" "system-udp-per-pkt" {
	name	= "System-UDP-Per-Pkt"
}
data "avi_vrfcontext" "default" {
	cloud_ref = data.avi_cloud.default.id
}
data "avi_vrfcontext" "vmware" {
	cloud_ref = data.avi_cloud.vmware.id
}

## create the avi vip
resource "avi_vsvip" "dns" {
	name		= "tf-vip-${var.vs_name}"
	tenant_ref	= data.avi_tenant.admin.id
	cloud_ref	= data.avi_cloud.vmware.id

	# static vip IP address
	vip {
		vip_id = "0"
		ip_address {
			type = "V4"
			addr = var.vs_address
		}
	}
	# dns domain name
	dns_info {
		fqdn	= var.vs_fqdn
		ttl	= 30
	}
}

## create the dns virtual service and attach vip
resource "avi_virtualservice" "dns1" {
	name			= "tf-vs-${var.vs_name}"
	fqdn			= var.vs_fqdn
	tenant_ref		= data.avi_tenant.admin.id
	cloud_ref		= data.avi_cloud.vmware.id
	vsvip_ref		= avi_vsvip.dns.id
	application_profile_ref	= data.avi_applicationprofile.system-dns.id
	network_profile_ref	= data.avi_networkprofile.system-udp-per-pkt.id
	se_group_ref		= data.avi_serviceenginegroup.mgmt.id
	services {
		port = 53
	}
	enabled			= true
}
```
