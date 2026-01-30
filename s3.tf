locals {
  policy_name = "gl-s3-policy"
}

resource "aws_iam_policy" "s3-policy" {
  name        = local.policy_name
  description = "IAM Polcicy for gl :aws_s3_buckets3 buckets"

  policy = <<EOT
{   "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:PutObjectAcl"
            ],
            "Resource": "arn:aws:s3:::gl-*/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:AbortMultipartUpload",
                "s3:ListMultipartUploadParts",
                "s3:ListBucketMultipartUploads"
            ],
            "Resource": "arn:aws:s3:::gl-*"
        }
    ]
}
EOT
}
