/*
16.04: ami-2757f631
16.10: ami-b374d5a5

*/

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_instance" "webserver" {
  ami           = "ami-2757f631"
  instance_type = "t2.micro"
  key_name = "TerraformKeyPair"
  user_data = file("deploy.sh")
  security_groups = ["WebServerSG"]
}