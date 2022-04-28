variable "env_name" {
  type    = string
  default = "staging"
}

variable "aws_region_name" {
  type = string
  default = "ap-south-1"
}

variable "exchange_name" {
  type = string
  default = "my_exchange"
}

variable "queue_name" {
  type = string
  default = "hello"
}