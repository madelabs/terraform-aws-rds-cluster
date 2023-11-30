resource "aws_kms_key" "cluster_storage_key" {
  count                   = var.create_kms_key ? 1 : 0
  description             = "KMS key for encrypting storage in the cluster ${local.cluster_identifier}."
  deletion_window_in_days = var.kms_key_deletion_window_in_days
  policy                  = data.aws_iam_policy_document.rds_cluster_kms_key_policy.json
  enable_key_rotation     = true
}

resource "aws_kms_alias" "alias" {
  count         = var.create_kms_key ? 1 : 0
  name          = "alias/${aws_kms_key.cluster_storage_key.key_id}"
  target_key_id = aws_kms_key.cluster_storage_key.key_id
}

data "aws_iam_policy_document" "rds_cluster_kms_key_policy" {
  statement {
    sid    = "Allow use of the key"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com"]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]

    resources = [aws_rds_cluster.cluster.arn]
  }

  statement {
    sid    = "Allow attachment of persistent resources"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com"]
    }

    actions = ["kms:CreateGrant", "kms:ListGrants", "kms:RevokeGrant"]

    resources = [aws_rds_cluster.cluster.arn]

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }
}
