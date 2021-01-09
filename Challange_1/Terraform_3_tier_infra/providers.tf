/*
AWS_deployer_Profile configured/set for specific account of AWS
*/
provider "aws" {
  version = "~> 1.0"
  region  = "eu-east-1"
  profile = "AWS_Deployer_Profile"
  alias   = "infra"
}

/*
Considering there is already a bucket name tfstate and profile AWS_Deployer_Profile
has permission to read and write on that
*/
terraform {
  backend "s3" {
    bucket = "tfstate"
    key    = "infra/application_tier3.tfstate"
    region = "eu-east-1"
  }
}





