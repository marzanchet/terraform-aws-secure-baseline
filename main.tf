
#Module      : CLOUDTRAIL
#Description : Terraform module to provision an AWS CloudTrail with encrypted S3 bucket.
#              This bucket is used to store CloudTrail logs.
module "cloudtrail" {
  source                            = "./modules/cloudtrail"
  name                              = "trails"
  application                       = var.application
  environment                       = var.environment
  managedby                         = var.managedby
  label_order                       = var.label_order
  enabled                           = var.enabled && var.cloudtrail_enabled
  iam_role_name                     = "CloudTrail-CloudWatch-Delivery-Role"
  iam_role_policy_name              = "CloudTrail-CloudWatch-Delivery-Policy"
  account_type                      = "individual"
  key_deletion_window_in_days       = var.key_deletion_window_in_days
  cloudwatch_logs_retention_in_days = var.cloudwatch_logs_retention_in_days
  cloudwatch_logs_group_name        = var.cloudwatch_logs_group_name
  EVENT_IGNORE_LIST                 = jsonencode(["^Describe*", "^Assume*", "^List*", "^Get*", "^Decrypt*", "^Lookup*", "^BatchGet*", "^CreateLogStream$", "^RenewRole$", "^REST.GET.OBJECT_LOCK_CONFIGURATION$", "TestEventPattern", "TestScheduleExpression", "CreateNetworkInterface", "ValidateTemplate"])
  EVENT_ALERT_LIST                  = jsonencode(["DetachRolePolicy", "ConsoleLogin"])
  USER_IGNORE_LIST                  = jsonencode(["^awslambda_*", "^aws-batch$", "^bamboo*", "^i-*", "^[0-9]*$", "^ecs-service-scheduler$", "^AutoScaling$", "^AWSCloudFormation$", "^CloudTrailBot$", "^SLRManagement$"])
  SOURCE_LIST                       = jsonencode(["aws-sdk-go"])
  s3_bucket_name                    = var.cloudtrail_bucket_name
  slack_webhook                     = var.slack_webhook
  slack_channel                     = var.slack_channel
}

#Module      : ALARM
#Description : Provides a CloudWatch Metric Alarm resource.
module "alarm" {
  source      = "./modules/alarm"
  name        = "alarm"
  application = var.application
  environment = var.environment
  managedby   = var.managedby
  label_order = var.label_order

  enabled                  = var.enabled && var.alarm_enabled
  unauthorized_api_calls   = var.unauthorized_api_calls
  no_mfa_console_signin    = var.no_mfa_console_signin
  root_usage               = var.root_usage
  iam_changes              = var.iam_changes
  cloudtrail_cfg_changes   = var.cloudtrail_cfg_changes
  console_signin_failures  = var.console_signin_failures
  disable_or_delete_cmk    = var.disable_or_delete_cmk
  s3_bucket_policy_changes = var.s3_bucket_policy_changes
  security_group_changes   = var.security_group_changes
  nacl_changes             = var.nacl_changes
  network_gw_changes       = var.network_gw_changes
  route_table_changes      = var.route_table_changes
  vpc_changes              = var.vpc_changes
  alarm_namespace          = var.alarm_namespace

  cloudtrail_log_group_name = module.cloudtrail.log_group_name
  variables = {
    SLACK_WEBHOOK = var.slack_webhook
    SLACK_CHANNEL = var.slack_channel
  }
}

#Module      : CONFIG BASELINE
#Description : Manages status (recording / stopped) of an AWS Config Configuration Recorder.
module "config" {
  source                = "./modules/config"
  name                  = "config"
  application           = var.application
  environment           = var.environment
  label_order           = var.label_order
  managedby             = var.managedby
  enabled               = var.enabled && var.config_enabled
  config_s3_bucket_name = var.config_s3_bucket_name

  # roles
  restricted_ports                   = var.restricted_ports
  restricted_ports_list              = var.restricted_ports_list
  iam_mfa                            = var.iam_mfa
  unused_credentials                 = var.unused_credentials
  user_no_policies                   = var.user_no_policies
  no_policies_with_full_admin_access = var.no_policies_with_full_admin_access
  acm_certificate_expiration_check   = var.acm_certificate_expiration_check
  ec2_volume_inuse_check             = var.ec2_volume_inuse_check
  ebs_snapshot_public_restorable     = var.ebs_snapshot_public_restorable
  rds_instance_public_access_check   = var.rds_instance_public_access_check
  rds_snapshots_public_prohibited    = var.rds_snapshots_public_prohibited
  guardduty_enabled_centralized      = var.guardduty_enabled_centralized
  s3_bucket_public_write_prohibited  = var.s3_bucket_public_write_prohibited
  eip_attached                       = var.eip_attached
  ec2_encrypted_volumes              = var.ec2_encrypted_volumes
  iam_root_access_key                = var.iam_root_access_key
  vpc_default_security_group_closed  = var.vpc_default_security_group_closed
  s3_bucket_ssl_requests_only        = var.s3_bucket_ssl_requests_only
  multi_region_cloudtrail_enabled    = var.multi_region_cloudtrail_enabled
  instances_in_vpc                   = var.instances_in_vpc
  cloudwatch_log_group_encrypted     = var.cloudwatch_log_group_encrypted
  rds_storage_encrypted              = var.rds_storage_encrypted

  iam_password_policy        = var.iam_password_policy
  password_require_uppercase = var.password_require_uppercase
  password_require_lowercase = var.password_require_lowercase
  password_require_symbols   = var.password_require_symbols
  password_require_numbers   = var.password_require_numbers
  password_min_length        = var.password_min_length
  password_reuse_prevention  = var.password_reuse_prevention
  password_max_age           = var.password_max_age

  variables = {
    SLACK_WEBHOOK = var.slack_webhook
    SLACK_CHANNEL = var.slack_channel
  }
}

#Module      :  GUARD DUTY
module "guardduty" {
  source                  = "./modules/guardduty"
  name                    = "guardduty"
  application             = var.application
  environment             = var.environment
  managedby               = var.managedby
  label_order             = var.label_order
  enabled                 = var.enabled && var.guardduty_enable
  bucket_name             = var.guardduty_s3_bucket_name
  ipset_format            = "TXT"
  ipset_iplist            = var.ipset_iplist
  threatintelset_activate = var.threatintelset_activate
  threatintelset_format   = "TXT"
  threatintelset_iplist   = var.threatintelset_iplist

  is_guardduty_member = var.is_guardduty_member
  member_list         = var.member_list
  variables = {
    minSeverityLevel = "LOW"
    webHookUrl       = var.slack_webhook
    slackChannel     = var.slack_channel
  }
}


## Inspector
module "inspector" {
  source = "./modules/inspector"

  ## Tags
  name        = "inspector"
  application = var.application
  environment = var.environment
  managedby   = var.managedby
  label_order = var.label_order
  enabled     = var.enabled && var.inspector_enabled

  instance_tags = {
    "Inspector" = true
  }

  duration            = 300
  rules_package_arns  = var.rules_package_arns
  lambda_enabled      = true
  schedule_expression = var.schedule_expression
  handler             = "index.handler"
  runtime             = "nodejs12.x"
  statement_ids       = ["AllowExecutionFromEvents"]
  actions             = ["lambda:InvokeFunction"]
  principals          = ["events.amazonaws.com"]

  iam_actions = [
    "inspector:StartAssessmentRun",
    "logs:CreateLogGroup",
    "logs:CreateLogStream",
    "logs:PutLogEvents"
  ]
}


## Analyzer
module "iam_access_analyzer" {
  source = "./modules/analyzer"

  name        = "analyzer"
  application = var.application
  environment = var.environment
  managedby   = var.managedby
  label_order = var.label_order
  enabled     = var.enabled && var.analyzer_enable

  ## IAM Access Analyzer
  type = var.type
  variables = {
    SLACK_WEBHOOK = var.slack_webhook
    SLACK_CHANNEL = var.slack_channel
  }
}