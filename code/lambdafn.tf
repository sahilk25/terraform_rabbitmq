resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.AWSLambdaTrustPolicy.json
}
resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment_lambda_vpc_access_execution" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment_lambda_secret_execution" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}


resource "aws_security_group" "sg_for_lambda" {

  name        = "lambda-sg"
  description = "lambda sg"
  vpc_id      = module.mq_vpc.vpc_id

  ingress {
    description      = "TLS from VPC"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["10.0.0.0/16"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  
}

resource "aws_lambda_function" "invoke_lambda" {
  # If the file is not in the current working directory you will need to include a 
  # path.module in the filename.
  filename      = "./invoke_lambda/invoke_lambda_function_payload.zip"
  function_name = "${var.env_name}-invoke_lambda"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"
  #VPC
  vpc_config {
    # Every subnet should be able to reach an EFS mount target in the same Availability Zone. Cross-AZ mounts are not permitted.
    subnet_ids         = module.mq_vpc.private_subnets
    security_group_ids = [aws_security_group.sg_for_lambda.id]
  }

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("./invoke_lambda/invoke_lambda_function_payload.zip")

  runtime = "python3.9"

  environment {
    variables = {
       RABBITMQ_HOST = aws_mq_broker.rabbitmq.instances.0.endpoints.0,
       #these should be encoded
       USER_NAME = jsondecode(data.aws_secretsmanager_secret_version.rabbitmq_secret.secret_string)["username"],
       USER_PASS = jsondecode(data.aws_secretsmanager_secret_version.rabbitmq_secret.secret_string)["password"],
       EXCHANGE_NAME = var.exchange_name
       QUE = var.queue_name
    }
  }
}


resource "aws_lambda_function_event_invoke_config" "invoke_lambda_config" {
  function_name                = aws_lambda_function.invoke_lambda.function_name
  maximum_event_age_in_seconds = 60
  maximum_retry_attempts       = 0
}


resource "aws_lambda_function" "read_lambda" {
  # If the file is not in the current working directory you will need to include a 
  # path.module in the filename.
  filename      = "./read_lambda/read_lambda_function_payload.zip"
  function_name = "${var.env_name}-read_lambda"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"
  #VPC
  vpc_config {
    # Every subnet should be able to reach an EFS mount target in the same Availability Zone. Cross-AZ mounts are not permitted.
    subnet_ids         = module.mq_vpc.private_subnets
    security_group_ids = [aws_security_group.sg_for_lambda.id]
  }

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("./read_lambda/read_lambda_function_payload.zip")

  runtime = "python3.9"

  environment {
    variables = {
       RABBITMQ_HOST = aws_mq_broker.rabbitmq.instances.0.endpoints.0,
       #these should be encoded
       USER_NAME = jsondecode(data.aws_secretsmanager_secret_version.rabbitmq_secret.secret_string)["username"],
       USER_PASS = jsondecode(data.aws_secretsmanager_secret_version.rabbitmq_secret.secret_string)["password"],
       EXCHANGE_NAME = var.exchange_name
       QUE = var.queue_name
    }
  }
}

resource "aws_lambda_event_source_mapping" "rabbitmq_invoke" {
  batch_size       = 10
  event_source_arn = aws_mq_broker.rabbitmq.arn
  enabled          = true
  function_name    = aws_lambda_function.read_lambda.arn
  queues           = [var.queue_name]

  source_access_configuration {
    type = "VIRTUAL_HOST"
    uri  = "/"
  }

  source_access_configuration {
    type = "BASIC_AUTH"
    uri  = data.aws_secretsmanager_secret_version.rabbitmq_secret.arn
  }
}
resource "aws_lambda_function_event_invoke_config" "read_lambda_config" {
  function_name                = aws_lambda_function.read_lambda.function_name
  maximum_event_age_in_seconds = 60
  maximum_retry_attempts       = 0
}