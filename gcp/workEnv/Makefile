get-modules:
	terraform init
	terraform get

plan: get-modules
	terraform plan -out workEnv.tfplan

apply: get-modules
	terraform apply workEnv.tfplan

destroy: get-modules
	terraform plan -destroy -out workEnv.tfplan

refresh:
	terraform refresh
