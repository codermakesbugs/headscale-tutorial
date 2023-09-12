provider "aws" {
    region = "ap-southeast-1"
    access_key = var.access_key
    secret_key = var.secret_key
}

resource "aws_instance" "headscale-server-instance" {
    ami                  = "ami-02acaf802ebcfdfde"
    instance_type        = "t2.micro"
    key_name             = var.key_name
    security_groups      = var.security_groups
    subnet_id            = var.subnet_id
    # iam_instance_profile = var.iam_instance_profile

    associate_public_ip_address  = true

    user_data = "${file("${var.user_data}")}"

    root_block_device  {
        delete_on_termination = true
        volume_size = var.volume_size
        volume_type = var.volume_type
        throughput  = 300
        tags = {
          "Name": "m:ebs:aps1c:public:headscale.aws.mesoneer.io:/root"
        }
    }

    ebs_block_device {
        # delete_on_termination = false
        device_name = "/dev/xvdb"
        volume_size = var.volume_size
        volume_type = var.volume_type
        throughput  = 300
        encrypted   = true
        tags = {
          "Name": "m:ebs:aps1c:public:headscale.aws.mesoneer.io:/apps"
        }
    }

    tags = {
        Name = "m:ec2:aps1c:public:headscale.aws.mesoneer.io"
        "ec2.aws.mesoneer.io/hostname" = "headscale.aws.mesoneer.io"
        "ec2.aws.mesoneer.io/autosnapshot" = "enabled"
        "ec2.aws.mesoneer.io/autosnapshot.retention-days" = 30
    }
}