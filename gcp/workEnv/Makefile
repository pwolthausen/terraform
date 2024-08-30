get-modules:
	terraform init
	terraform get

plan: get-modules
	terraform plan -out workEnv.tfplan

apply: get-modules
	terraform apply workEnv.tfplan

destroy: get-modules
	terraform plan -destroy -out workEnv.tfplan

out-plan:
	terraform show workEnv.tfplan -no-color > workEnv_tfplan.txt

refresh:
	terraform refresh
