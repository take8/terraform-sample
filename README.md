# Terraform Sample

Terraformのサンプルプロジェクト

## 準備

### AWS Credentials

AWSでユーザーを作成

### `tfstate`保存用のS3バケットを作成

```sh
aws s3api create-bucket --bucket TFSTATE_BUCKET_NAME --region ap-northeast-1 --create-bucket-configuration LocationConstraint=ap-northeast-1
```
