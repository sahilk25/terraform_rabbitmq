data "aws_availability_zones" "avz_list" {
  state = "available"

  filter {
    name   = "region-name"
    values = toset([var.aws_region_name])
  }
}

# data "aws_ssm_parameter" "rabbitmq_user" {
#   name = "rabbitmq_user"
# }

# data "aws_ssm_parameter" "rabbitmq_userpass" {
#   name = "rabbitmq_userpass"
# }

data "aws_iam_policy_document" "AWSLambdaTrustPolicy" {
  version = "2012-10-17"
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_secretsmanager_secret" "rabbitmq" {
  name = "rabbitmq"
}

data "aws_secretsmanager_secret_version" "rabbitmq_secret" {
  secret_id     = data.aws_secretsmanager_secret.rabbitmq.id
}

# jsondecode(data.aws_secretsmanager_secret_version.rabbitmq_secret.secret_string)["username"]
# jsondecode(data.aws_secretsmanager_secret_version.rabbitmq_secret.secret_string)["password"]