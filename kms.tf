resource "aws_kms_key" "cluster_storage_key" {
  count                   = var.create_kms_key ? 1 : 0
  description             = "KMS key for encrypting storage in the cluster ${local.cluster_identifier}."
  deletion_window_in_days = var.kms_key_deletion_window_in_days
  enable_key_rotation     = true
}

resource "aws_kms_alias" "alias" {
  count         = var.create_kms_key ? 1 : 0
  name          = "alias/${local.cluster_identifier}-storage-key"
  target_key_id = aws_kms_key.cluster_storage_key[0].key_id
}

resource "aws_kms_key_policy" "cluster_storage_key_policy" {
  count  = var.create_kms_key ? 1 : 0
  key_id = aws_kms_key.cluster_storage_key[0].key_id
  policy = data.aws_iam_policy_document.cluster_storage_key_policy[0].json
}

data "aws_iam_policy_document" "cluster_storage_key_policy" {
  count = var.create_kms_key ? 1 : 0
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

    resources = ["*"]
  }

  statement {
    sid    = "Allow attachment of persistent resources"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com"]
    }

    actions = ["kms:CreateGrant", "kms:ListGrants", "kms:RevokeGrant"]

    resources = ["*"]

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }

  statement {
    sid    = "Allow key administration"
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
      "${data.aws_iam_session_context.context.issuer_arn}"]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }
}

data "aws_caller_identity" "current" {}

data "aws_iam_session_context" "context" {
  arn = data.aws_caller_identity.current.arn
}
