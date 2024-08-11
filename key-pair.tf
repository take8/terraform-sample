locals {
  key_name = format("%s-%s-administrator", var.project_name, var.environment)
}

# 作成したキーペアを格納するファイルを指定
locals {
  public_key_file  = "./.key_pair/${local.key_name}.id_rsa.pub"
  private_key_file = "./.key_pair/${local.key_name}.id_rsa"
}

# privateキーのアルゴリズム
resource "tls_private_key" "keygen" {
  algorithm = "ED25519"
}

# local_fileのリソースを指定するとterraformを実行するディレクトリ内でファイル作成やコマンド実行が可能
resource "local_sensitive_file" "private_key_openssh" {
  filename        = local.private_key_file
  content         = tls_private_key.keygen.private_key_openssh
  file_permission = "0600"
}

resource "local_file" "public_key_openssh" {
  filename        = local.public_key_file
  content         = tls_private_key.keygen.public_key_openssh
  file_permission = "0600"
}
