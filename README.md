# Curacado AWS ECR Terraform Module

Terraform module to provision an AWS ECR Repository.

## Requirements

This module requires Terraform `>= 1.5.0` and  AWS Provider `>= 5.13.0`.

## Usage

**IMPORTANT:** This example uses a hardcoded version tag that does not exist. This tag must be replaced with the most current one.

```hcl
module "ecr" {
  source               = "git@github.com:CuracadoGit/tf-ecr?ref=99.99.99"
  kms_key_arn          = var.kms_key_arn
  name                 = "example-name"
  read_principal_arns  = [module.ecs.execution_role_arn]
  write_principal_arns = [aws_iam_user.jenkins.arn]
}
```

## Inputs
| Name                         | Description                                                                                             | Type           | Default | Required |
|------------------------------|---------------------------------------------------------------------------------------------------------|----------------|---------|:--------:|
| name                         | The name for the ECR                                                                                    | `string`       | n/a     |   yes    |
| read_principal_arns          | ARNs of principals (e.g. a task execution role) that will be granted permission to read from the ECR    | `list(string)` | n/a     |   yes    |
| write_principal_arns         | ARNs of principals (e.g. automation user) that will be granted write access in order to push new images | `list(string)` | n/a     |   yes    |
| kms_key_arn                  | ARN of KMS key that will be used to encrypt images                                                      | `string`       | n/a     |   yes    |
| scan_on_push                 | Scan images on push                                                                                     | `bool`         | `true`  |    no    |
| keep_last_images             | Restrict the number of images to the latest x                                                           | `number`       | `10`    |    no    |
| remove_untagged_images_after | Removes all untagged images that are older than the given value in days                                 | `number`       | 14      |    no    |
| image_tag_mutability         | Allows an image tag to be updated                                                                       | `bool`         | `false` |    no    |

## Outputs

| Name           | Description                    |
|----------------|--------------------------------|
| repository_url | The full URL of the repository |