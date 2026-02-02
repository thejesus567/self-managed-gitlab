locals {
  policy_name = "gl-s3-policy"
  role_name   = "GitLabS3Access"
}

data "aws_iam_policy_document" "s3-policy-document" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:PutObjectAcl"
    ]
    resources = ["arn:aws:s3:::gl-*/*"]
    effect    = "Allow"
  }
  statement {
    actions = [
      "s3:ListBucket",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts",
      "s3:ListBucketMultipartUploads"
    ]
    resources = ["arn:aws:s3:::gl-*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "s3-policy" {
  name        = local.policy_name
  description = "IAM Polcicy for gl :aws_s3_buckets3 buckets"
  policy      = data.aws_iam_policy_document.s3-policy-document
}


data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}


resource "aws_iam_role" "instance" {
  name               = local.role_name
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json

  inline_policy {
    name   = "policy-8675309"
    policy = aws_iam_policy.s3-policy
  }
}
