get-modules:
	terraform init
	terraform get

plan: get-modules
	terraform plan -out sandbox.tfplan

apply: get-modules
	terraform apply sandbox.tfplan

destroy: get-modules
	terraform plan -destroy -out sandbox.tfplan

refresh:
	terraform refresh
