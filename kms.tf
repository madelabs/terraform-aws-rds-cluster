resource "aws_kms_key" "cluster_storage_key" {
  count                   = var.create_kms_key ? 1 : 0
  description             = "KMS key for encrypting storage in the cluster ${local.cluster_identifier}."
  deletion_window_in_days = var.kms_key_deletion_window_in_days
  enable_key_rotation     = true
}

resource "aws_kms_alias" "alias" {
  count         = var.create_kms_key ? 1 : 0
  name          = "alias/${aws_kms_key.cluster_storage_key[0].key_id}"
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
      type        = "AWS"
      identifiers = ["arn:aws:iam::569510392077:role/tfc-deployment"]
    }

    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion",]

    resources = ["*"]

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }
}
