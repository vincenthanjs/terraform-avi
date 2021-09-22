# vsphere  parameters
vcenter_server		= "sun05-vcenter02.acepod.com"
vcenter_username	= "administrator@vsphere.local"
vcenter_password	= "VMware1!"
datacenter			= "SUN01"

# avi parameters
avi_server			= "10.115.1.41"
avi_username		= "admin"
avi_password		= "VMware1!"
avi_version			= "21.1.1"

# vcenter cloud configuration
cloud_name		= "tf-vmware-cloud"
vcenter_license_tier	= "ENTERPRISE"
vcenter_license_type	= "LIC_CORES"
vcenter_configuration	= {
	username			= "administrator@vsphere.local"
	password			= "VMware1!"
	vcenter_url			= "sun05-vcenter02.acepod.com"
	datacenter			= "SUN05"
	management_network	= "VDS01-VLAN115-IaaS"
	privilege			= "WRITE_ACCESS"
}
