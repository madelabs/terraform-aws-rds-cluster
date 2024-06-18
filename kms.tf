resource "aws_kms_key" "cluster_storage_key_1" {
  count                   = var.create_kms_key ? 1 : 0
  description             = "KMS key for encrypting storage in the cluster ${local.cluster_identifier}."
  deletion_window_in_days = var.kms_key_deletion_window_in_days
  enable_key_rotation     = true
}

resource "aws_kms_alias" "alias" {
  count         = var.create_kms_key ? 1 : 0
  name          = "alias/${aws_kms_key.cluster_storage_key_1[0].key_id}"
  target_key_id = aws_kms_key.cluster_storage_key_1[0].key_id
}

resource "aws_kms_key_policy" "cluster_storage_key_policy" {
  count  = var.create_kms_key ? 1 : 0
  key_id = aws_kms_key.cluster_storage_key_1[0].key_id
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
      identifiers = [data.aws_iam_session_context.context.issuer_arn]
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
      "kms:CancelKeyDeletion", ]

    resources = ["*"]

  }
}

data "aws_caller_identity" "current"{}

data "aws_iam_session_context" "context" {
  arn = data.aws_caller_identity.current.arn
}

output "caller_arn"{
  value = data.aws_caller_identity.current.arn
}

output "caller_user_id"{
  value = data.aws_caller_identity.current.user_id
}

output "caller_id"{
  value = data.aws_caller_identity.current.id
}

output "caller_account_id"{
  value = data.aws_caller_identity.current.account_id
}

# locals{
#   executing-identity = data.aws_caller_identity.current.id #"arn:aws:iam::569510392077:role/tfc-deployment"
# }

