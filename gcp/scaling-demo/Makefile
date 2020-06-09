get-modules:
	terraform init
	terraform get

plan: get-modules
	terraform plan -state demo.tfstate -var-file variables.tfvars -out demo.tfplan

apply: get-modules
	terraform apply -state-out demo.tfstate demo.tfplan

destroy: get-modules
	terraform plan -destroy -var-file variables.tfvars -out demo.tfplan -state demo.tfstate

refresh:
	terraform refresh -var-file variables.tfvars -state demo.tfstate
