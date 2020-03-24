get-modules:
	terraform init
	terraform get

plan: get-modules
	terraform plan -state frontier.tfstate -var-file variables.tfvars -out frontier.tfplan

apply: get-modules
	terraform apply -state-out frontier.tfstate frontier.tfplan

destroy: get-modules
	terraform plan -destroy -var-file variables.tfvars -out frontier.tfplan -state frontier.tfstate

refresh:
	terraform refresh -var-file variables.tfvars -state frontier.tfstate
