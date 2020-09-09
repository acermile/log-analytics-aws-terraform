provider "aws" {
  region  = var.aws-region
  profile = var.AWS_PROFILE //give the profile of your AWS account
  version = ">= 2.28.1"
}
