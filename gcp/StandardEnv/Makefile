get-modules:
	terraform init
	terraform get

plan: get-modules
	terraform plan -state WebEnv.tfstate -var-file variables.tfvars -out WebEnv.tfplan

apply: get-modules
	terraform apply -state-out WebEnv.tfstate WebEnv.tfplan

destroy: get-modules
	terraform plan -destroy -var-file variables.tfvars -out WebEnv.tfplan -state WebEnv.tfstate

refresh:
	terraform refresh -var-file variables.tfvars -state WebEnv.tfstate
