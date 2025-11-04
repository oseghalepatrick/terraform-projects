apply: plan
	terraform apply -var-file=terraform.tfvars -auto-approve

plan: init
	terraform plan -var-file=terraform.tfvars

init: fmt
	terraform init -var-file=terraform.tfvars -backend-config=backend-config.hcl -migrate-state

fmt:
	terraform fmt -recursive