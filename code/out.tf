output "rabbitmq_endpoint" {
  value = aws_mq_broker.rabbitmq.instances
}