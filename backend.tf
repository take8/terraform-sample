terraform {
  backend "s3" {
    bucket  = "TFSTATE_BUCKET_NAME"
    region  = "ap-northeast-1"
    profile = "default"
    key     = "terraform.tfstate"
    encrypt = true
  }
}
