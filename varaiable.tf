variable "Subnet1" {
    default = "10.0.2.0/24"
  }
  
variable "Subnet"{
    default = "10.0.1.0/24"
}

variable "AccessKeyID"{
    default = "AKIARP4KQO6STDJEB3H2"
}

variable "SecretAccessKey"{
    default = "kobft5WR99ug1IjOEIw/xI010b9R3Iy4Nxho9cFF"
}

variable "Blue_WebServer-AMID"{
    default = "ami-0dbc3d7bc646e8516"
}

variable "Green_WebServer-AMID"{
    default = "ami-0dbc3d7bc646e8516"
}


output First-Web-server-1a{
    value = [aws_instance.First-Web-server-1a.public_ip,aws_instance.First-Web-server-1a.private_ip]
}

output First-Web-server-1b {
    value = aws_instance.First-Web-server-1b.public_ip
}

output Second-Web-server-1a {
    value = aws_instance.Second-Web-server-1a.public_ip
}


output Second-Web-server-1b{
    value = aws_instance.Second-Web-server-1b.public_ip
}