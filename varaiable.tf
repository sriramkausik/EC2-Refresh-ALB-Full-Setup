variable "Subnet1" {
    default = "10.0.2.0/24"
  }
  
variable "Subnet"{
    default = "10.0.1.0/24"
}

variable "AccessKeyID"{
    default = "AKIAZ32JIMXS4KZWZPDB"
}

variable "SecretAccessKey"{
    default = "Iv/PuHpXp5ZmxRsAIDXAoVp5CpLXVzHWuyV7alS/"
}

variable "Blue_WebServer-AMID"{
    default = "ami-0dbc3d7bc646e8516"
}

variable "Green_WebServer-AMID"{
    default = "ami-0dbc3d7bc646e8516"
}

variable "Swing_percentage_Blue" {
    default = 50
  }
  
  variable "Swing_percentage_Green" {
    default = 50
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