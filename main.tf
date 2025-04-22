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

  policy = jsonencode({
    "rules" : concat(
      [
        {
          rulePriority : 100,
          description : "Remove untagged images older than 14 days",
          selection : {
            tagStatus : "untagged",
            countType : "sinceImagePushed",
            countUnit : "days",
            countNumber : var.remove_untagged_images_after
          },
          action : {
            type : "expire"
          }
        },
        {
          rulePriority : 200,
          description : "Keep last ${var.keep_last_images} images",
          selection : {
            tagStatus : "any",
            countType : "imageCountMoreThan",
            countNumber : var.keep_last_images
          },
          action : {
            type : "expire"
          }
        }
      ],

      # add a rule for each tag that prevents images from being deleted.
      # these rules have a high priority and will be matched against images first.
      # once an image was matched by a rule, no following rule is evaluated against it.
      # this means that all images matched by this rule block will be exempt from all following rules.
      [
        for pos, tag in concat(["latest"], var.never_expire_tags) : {
          rulePriority : 10 + pos,
          description : "preserve images with tag `${tag}`",
          # select all images ...
          selection : {
            # ... that are tagged ...
            tagStatus : "tagged",
            # ... with this specific tag ...
            tagPrefixList : [tag],
            # ... and if there are more than ...
            countType : "imageCountMoreThan",
            # ... this huge number (spoiler: there aren't) ...
            countNumber : 999999
          },
          action : {
            # ... delete the oldest ones.
            type : "expire"
          }
        }
      ]
    ),
  })

}