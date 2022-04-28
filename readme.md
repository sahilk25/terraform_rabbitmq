## Dev container
    Container development, It has all the requirement to run and test the code
    Tf and lambda code are in Code folder
## Terraform code 
1. VPC with public and private subnet
2. Rabbitmq single instance deployed with in private subnet
3. 2 lambda fn

## lambda
1. Invoke lambda
    This will push msg to rabbitmq with exchange and que

2. Read lambda
    This lambda is triggerd by rabbitmq and put the msg logs in cloudwatch

