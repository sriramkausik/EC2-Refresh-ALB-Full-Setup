variable "Subnet1" {
    default = "10.0.2.0/24"
  }
  
variable "Subnet"{
    default = "10.0.1.0/24"
}

variable "AccessKeyID"{
    default = "AKIAYPRFPOE2USRXBBM2"
}

variable "SecretAccessKey"{
    default = "ugBIm7AhFyrJXNMdn5Xf4tYcJEfBQ+IbaWxiwy9A"
}

variable "Blue_WebServer-AMID"{
    default = "ami-01bc990364452ab3e"
}

variable "Green_WebServer-AMID"{
    default = "ami-01bc990364452ab3e"
}

variable "Swing_percentage_Blue" {
    default = 50
  }
  
  variable "Swing_percentage_Green" {
    default = 50
  }
output Blue-1{
    value = aws_instance.First-Web-server-1a.public_ip
}

output Green-1 {
    value = aws_instance.First-Web-server-1b.public_ip
}

output Blue-2 {
    value = aws_instance.Second-Web-server-1a.public_ip
}


output Green-2{
    value = aws_instance.Second-Web-server-1b.public_ip
}

output ALB{
    value = aws_lb.ALB.dns_name
   
}

output Weight{

    value = aws_lb_listener.ALBLISTEN.default_action
   
}
