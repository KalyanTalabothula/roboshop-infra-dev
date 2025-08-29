# 🔍  terraform remote state s3 bucket

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.98.0"
    }
  }

# 🔍  terraform remote state s3 bucket

  backend "s3" {        # <-- backend is ntg but state ani ardham.
    bucket = "s3-kalyan-bucket-dev"   # <--- dev ani echhanm
    key    = "roboshop-dev-acm"    # <--- giving key as "remote-state-demo"
    region = "us-east-1"
    encrypt = true
    use_lockfile = true 
    #dynamodb_table = "84s-remote-state"  # <-- mention table name
  }
}

provider "aws" {      
  # Configuration options  
  region = "us-east-1"
}

