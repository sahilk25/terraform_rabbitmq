resource "aws_mq_broker" "rabbitmq" {
  broker_name = "${var.env_name}-rabbitmq"

  engine_type        = "RabbitMQ"
  engine_version     = "3.9.13"
  storage_type       = "ebs"
  host_instance_type = "mq.t3.micro"
  security_groups    = [aws_security_group.sg_rabbitmq.id]
  #VPC
  publicly_accessible = false
  deployment_mode = "SINGLE_INSTANCE"
  subnet_ids = [module.mq_vpc.private_subnets[0]]
  logs {
      general = true
  }
  
  tags = {
    "terraform-env" = "${var.env_name}"
  }

  user {
    username = jsondecode(data.aws_secretsmanager_secret_version.rabbitmq_secret.secret_string)["username"]
    password = jsondecode(data.aws_secretsmanager_secret_version.rabbitmq_secret.secret_string)["password"]
  }

}
resource "aws_security_group" "sg_rabbitmq" {

  name        = "sg_rabbitmq"
  description = "sg_rabbitmq"
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