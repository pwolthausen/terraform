get-modules:
	terraform init
	terraform get

plan: get-modules
	terraform plan -var-file variables.tfvars -out multidisk.tfplan

apply: get-modules
	terraform apply multidisk.tfplan

destroy: get-modules
	terraform plan -destroy -var-file variables.tfvars -out multidisk.tfplan

refresh:
	terraform refresh -var-file variables.tfvars
