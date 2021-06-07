## `terraform-avi`
A collection of terraform plans for the `avi networks` load-balancing platform  
Clone repository and adjust parameters as required  

---

### `clone`
```
git clone https://github.com/apnex/terraform-avi
cd terraform-avi
```

---

### `phases`
This repo is organised into 3 key phases as follows:  

<pre>
terraform-avi
  &#x2523&#x2501 phase0-deploy
  &#x2523&#x2501 phase1-infra
  &#x2517&#x2501 phase2-dns
</pre>

Each phase and directory represents a single atomic terraform plan for avi deployment or configuration.  
Modify parameters as necessary in each `main.tf` and `apply` or `destroy` as required.

---

#### [`>> phase0-deploy <<`](phase0-deploy/README.md)
Deploys the avi controller vm to a target `vcenter` platform.  
This will take some time copy the ova and start the appliance services.  

**Note: After completing this `plan` you must login and complete the one-time `Welcome Setup` workflow**

---

#### [`>> phase1-infra <<`](phase1-infra/README.md)
Configures `avi` with the following infrastructure geometry:  

<pre>
vcenter-cloud
 &#x2523&#x2501 ipam-profile
 &#x2523&#x2501 dns-profile
 &#x2517&#x2501 se-groups
     &#x2523&#x2501 Default-Group (cmp cluster)
     &#x2517&#x2501 mgmt-se-group (mgmt cluster)
</pre>

---

#### [`>> phase2-dns <<`](phase2-dns/README.md)
Configures a DNS virtual service in `mgmt-se-group`  
This will trigger the `service-engine` vm creation in vsphere and may take some time to complete.  

**Note: After completing this `plan` you must login and enable `Administration > Settings > DNS Service`**
