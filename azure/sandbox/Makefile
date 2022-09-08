get-modules:
	terraform init
	terraform get

plan: get-modules
	terraform plan -var-file variables.tfvars -out sandbox.tfplan

apply: get-modules
	terraform apply sandbox.tfplan

destroy: get-modules
	terraform plan -destroy -var-file variables.tfvars -out sandbox.tfplan

refresh:
	terraform refresh -var-file variables.tfvars
