terraform {
  backend "s3" {
    bucket = "xyzsahil-tfstate"
    key    = "terra/staging_state.tfstate"
    region = "ap-south-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}