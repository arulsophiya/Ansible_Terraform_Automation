variable "environment" {
  description = "Environment Name"
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ami" {
  description = "AMI for ansible controller"
  type        = string
  default     = "ami-0df24e148fdb9f1d8"
}

variable "web_ami" {
  description = "AMI for the webserver"
  type        = string
  default     = "ami-0efa651876de2a5ce"
}

variable "ssh_user_name" {
  description = "SSH username"
  type        = string
  default     = "ec2-user"
}
