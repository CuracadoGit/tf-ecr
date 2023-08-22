resource "aws_ecr_repository" "this" {
  name = var.name

  image_tag_mutability = var.image_tag_mutability ? "MUTABLE" : "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = var.kms_key_arn
  }
}

data "aws_iam_policy_document" "this" {
  statement {
    sid    = "AllowPull"
    effect = "Allow"
    principals {
      identifiers = var.read_principal_arns
      type        = "AWS"
    }
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:DescribeImages"
    ]
  }

  statement {
    sid    = "AllowPushPull"
    effect = "Allow"
    principals {
      identifiers = var.write_principal_arns
      type        = "AWS"
    }
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:GetAuthorizationToken"
    ]
  }

}


resource "aws_ecr_repository_policy" "this" {
  policy     = data.aws_iam_policy_document.this.json
  repository = aws_ecr_repository.this.name
}

resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last ${var.keep_last_images} images",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["v"],
                "countType": "imageCountMoreThan",
                "countNumber": ${var.keep_last_images}
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}