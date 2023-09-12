variable "access_key" {
  default = "AKIAY3TIA4EOFR5K2HX5"
}

variable "secret_key" {
  default = "DOp4UQ3DgJZIJ7BNrIj99ZV+IzWEpCKL2dFy6HaZ"
}

variable "key_name" {
  default = "my-aws-key"
}

variable "user_data" {
  default = "/Users/lupinkis/Desktop/headscale-config/headscale.ign"
}

variable "security_groups" {
  default = ["sg-048033f506ad43a1d"]
}

variable "subnet_id" {
    default = "subnet-06499cad625bba86d"
}

variable "iam_instance_profile" {
    default = "Name=ubitec-ecr-reader"
}

variable "volume_size" {
    default = 16
}

variable "volume_type" {
    default = "gp3"
}
