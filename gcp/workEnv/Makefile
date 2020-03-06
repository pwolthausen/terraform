get-modules:
	terraform init
	terraform get

plan: get-modules
	terraform plan -state workEnv.tfstate -var-file variables.tfvars -out workEnv.tfplan

apply: get-modules
	terraform apply -state-out workEnv.tfstate workEnv.tfplan

destroy: get-modules
	terraform plan -destroy -var-file variables.tfvars -out workEnv.tfplan -state workEnv.tfstate

refresh:
	terraform refresh -var-file variables.tfvars -state workEnv.tfstate
