## `terraform-avi`
A collection of terraform plans for the AVI networks platform  
Clone repository and adjust parameters as required  

#### `clone`
```
git clone https://github.com/apnex/terraform-avi
cd terraform-avi
```

#### `parameters`
Verify and adjust parameters of `main.tf` in each sub-directory to suit deployment target or intent

#### `init`
Initialise terraform provider
```
terraform init
```

#### `plan`
Run plan and review changes
```
terraform plan
```

#### `apply`
Apply the plan
```
terraform apply
```

#### `destroy` [OPTIONAL]
Destroy resources
```
terraform destroy
```
