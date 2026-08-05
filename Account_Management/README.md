This directory holds IaC for AWS deployment.

## MFA
    ```
    aws configure export-credentials --profile infra-engineer --format powershell | Invoke-Expression
    ```

## Testing
- Stand up infrastructure by running command in /infra directory.
    ```
    terraform init
    terraform apply -var-file="_$(terraform workspace show).tfvars"
    ```

## Cleanup Resources
- Plan Destroy
    ```
    terraform plan -destroy -var-file="_$(terraform workspace show).tfvars"
    ```
- Terraform Destroy
    ```
    terraform destroy -var-file="_$(terraform workspace show).tfvars"
    ```
