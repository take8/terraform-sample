# Terraform Sample

Terraformのサンプルプロジェクト

- SSHログインのための公開鍵を登録
- SSHログインのためのSGを登録
- Webサーバーとして2台のEC2インスタンスを構築
- それぞれのEC2インスタンスにEIPを設定

## 準備

### AWS Credentials

AWSでユーザーを作成

### `tfstate`保存用のS3バケットを作成

```sh
aws s3api create-bucket --bucket TFSTATE_BUCKET_NAME --region ap-northeast-1 --create-bucket-configuration LocationConstraint=ap-northeast-1
```

## ワークスペースの切り替え

```sh
# 一覧
terraform workspace list

# 切り替え
terraform workspace select ${ENVIRONMENT}
```

## フォーマット

```sh
terraform fmt
```

## テスト

```sh
terraform validate
```

## デプロイ

```sh
# 確認
terraform plan

# 実行
terraform apply
```
