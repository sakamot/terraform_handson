// 変数を宣言
variable "server_name" {}
variable "subnet_id" {}
variable "security_group_id" {}
variable "instance_type" {
  default = "t3.micro"
}

data "aws_ami" "recent_amazon_linux_2" {
  // 条件に当てはまる複数の結果が返ってきたとき、最新のAMIを返す
  most_recent = true
  // AMIの所有者情報で絞り込む。今回はAWS公式AMIを使うためamazonを指定
  owners      = ["amazon"]

  // AMIの検索条件
  // aws-cliのdescribe-imagesと記法は同じ
  // AMIの名前を条件に検索
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.????????-x86_64-gp2"]
  }

  // AMIのstateを2つ目の条件に追加
  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_instance" "example" {
  ami           = data.aws_ami.recent_amazon_linux_2.image_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  // セキュリティグループはsecurity_groupsではなくvpc_security_group_idsで設定すること
  // さもないとセキュリティグループの設定を追加した時にインスタンス削除→再構築されてしまう
  // security_groupsを使うとapplyされたときにEC2が再起動されたりする
  vpc_security_group_ids = [var.security_group_id]

  user_data = <<EOF
    #!/bin/bash
    yum install -y httpd
    systemctl start httpd.service
EOF

  tags = {
    Name      = var.server_name
    ManagedBy = "Terraform"
  }
}
