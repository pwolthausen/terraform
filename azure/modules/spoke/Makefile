get-modules:
	terraform init
	terraform get

plan: get-modules
	terraform plan -out plan.tfplan

apply: get-modules
	terraform apply plan.tfplan

destroy: get-modules
	terraform plan -destroy -out plan.tfplan

refresh:
	terraform refresh
