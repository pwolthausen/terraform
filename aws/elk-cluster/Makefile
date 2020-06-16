get-modules:
	terraform init
	terraform get

plan: get-modules
	terraform plan -state elk-cluster.tfstate -var-file variables.tfvars -out elk-cluster.tfplan

apply: get-modules
	terraform apply -state-out elk-cluster.tfstate elk-cluster.tfplan

destroy: get-modules
	terraform plan -destroy -var-file variables.tfvars -out elk-cluster.tfplan -state elk-cluster.tfstate

refresh:
	terraform refresh -var-file variables.tfvars -state elk-cluster.tfstate
