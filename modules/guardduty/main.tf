locals {
  ipset_key          = "ipset.txt"
  threatintelset_key = "threatintelset.txt"
}

data "aws_caller_identity" "current" {}

module "labels" {
  source  = "clouddrove/labels/aws"
  version = "0.15.0"

  name        = var.name
  environment = var.environment
  label_order = var.label_order
  managedby   = var.managedby
}

#tfsec:ignore:aws-s3-block-public-acls
#tfsec:ignore:aws-s3-block-public-policy
#tfsec:ignore:aws-s3-enable-bucket-encryption
#tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket" "bucket" {
  count         = var.enabled ? 1 : 0
  bucket        = var.bucket_name
  force_destroy = true
}

resource "aws_guardduty_detector" "detector" {
  count                        = var.enabled ? 1 : 0
  enable                       = var.guardduty_enable
  finding_publishing_frequency = var.finding_publishing_frequency
}

resource "aws_guardduty_invite_accepter" "member_accepter" {
  count             = var.enabled && var.is_guardduty_member ? 1 : 0
  detector_id       = join("", aws_guardduty_detector.detector.*.id)
  master_account_id = data.aws_caller_identity.current.account_id
}

resource "aws_s3_bucket_object" "ipset" {
  count = var.enabled ? 1 : 0
  acl   = "private"
  content = templatefile("${path.module}/templates/ipset.txt.tpl",
  { ipset_iplist = var.ipset_iplist })
  bucket        = join("", aws_s3_bucket.bucket.*.id)
  key           = local.ipset_key
  force_destroy = true
  tags          = module.labels.tags
}

resource "aws_guardduty_ipset" "ipset" {
  count       = var.enabled ? 1 : 0
  activate    = var.ipset_activate
  detector_id = join("", aws_guardduty_detector.detector.*.id)
  format      = var.ipset_format
  location    = "https://s3.amazonaws.com/${join("", aws_s3_bucket_object.ipset.*.bucket)}/${join("", aws_s3_bucket_object.ipset.*.key)}"
  name        = format("%s-ipset", module.labels.id)
}

resource "aws_s3_bucket_object" "threatintelset" {
  count = var.enabled ? 1 : 0
  acl   = "private"
  content = templatefile("${path.module}/templates/threatintelset.txt.tpl",
  { threatintelset_iplist = var.threatintelset_iplist })
  bucket        = join("", aws_s3_bucket.bucket.*.id)
  key           = local.threatintelset_key
  force_destroy = true
  tags          = module.labels.tags
}

resource "aws_guardduty_threatintelset" "threatintelset" {
  count       = var.enabled ? 1 : 0
  activate    = var.threatintelset_activate
  detector_id = join("", aws_guardduty_detector.detector.*.id)
  format      = var.threatintelset_format
  location    = "https://s3.amazonaws.com/${join("", aws_s3_bucket_object.threatintelset.*.bucket)}/${join("", aws_s3_bucket_object.threatintelset.*.key)}"
  name        = format("%s-threat", module.labels.id)
}

resource "aws_guardduty_member" "member" {
  count                      = var.enabled && var.is_guardduty_member ? length(var.member_list) : 0
  account_id                 = var.member_list[count.index]["account_id"]
  detector_id                = join("", aws_guardduty_detector.detector.*.id)
  email                      = var.member_list[count.index]["email"]
  invite                     = var.member_list[count.index]["invite"]
  invitation_message         = "Please accept guardduty invitation"
  disable_email_notification = var.disable_email_notification
}

#Module      : CLOUD WATCH EVENT RULE
#Description : Event rule for cloud watch events.
resource "aws_cloudwatch_event_rule" "default" {
  count       = var.enabled ? 1 : 0
  name        = format("%s-er", module.labels.id)
  description = "Event rule for AWS Guarddduty."
  role_arn    = var.rule_iam_role_arn
  is_enabled  = var.enabled
  tags        = module.labels.tags

  event_pattern = <<PATTERN
  {
    "source": [
      "aws.guardduty"
    ],
    "detail-type": [
      "GuardDuty Finding"
    ]
  }
  PATTERN
}

#Module      : CLOUD WATCH EVENT TARGET
#Description : Attaching event rule and lambda function to targets.
resource "aws_cloudwatch_event_target" "default" {
  count     = var.enabled && var.slack_enabled ? 1 : 0
  rule      = join("", aws_cloudwatch_event_rule.default.*.name)
  target_id = "Guardduty"
  arn       = module.slack-lambda.arn # ARN of the Lambda Function, write after including lambda function
  role_arn  = var.target_iam_role_arn
}


module "slack-lambda" {
  source  = "clouddrove/lambda/aws"
  version = "0.15.0"

  name        = format("%s-slack-lambda", module.labels.id)
  environment = var.environment
  label_order = ["name"]
  managedby   = var.managedby
  enabled     = var.enabled && var.slack_enabled

  filename = format("%s/slack", path.module)
  handler  = "index.handler"
  runtime  = "nodejs12.x"
  iam_actions = [
    "xray:PutTraceSegments",
    "xray:PutTelemetryRecords",
    "xray:GetSamplingRules",
    "xray:GetSamplingTargets",
    "xray:GetSamplingStatisticSummaries",
    "logs:CreateLogGroup",
    "logs:CreateLogStream",
    "logs:PutLogEvents",
    "ec2:CreateNetworkInterface",
    "ec2:DescribeNetworkInterfaces",
    "ec2:DeleteNetworkInterface",
    "events:*"
  ]
  timeout = 30

  statement_ids = [
    "AllowExecutionFromCloudWatch"
  ]
  actions = [
    "lambda:InvokeFunction"
  ]
  principals = [
    "events.amazonaws.com"
  ]
  source_arns = [join("", aws_cloudwatch_event_rule.default.*.arn)]
  variables   = var.variables
}
