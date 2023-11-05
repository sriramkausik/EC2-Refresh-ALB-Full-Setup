variable "Subnet1" {
    default = "10.0.2.0/24"
  }
  
variable "Subnet"{
    default = "10.0.1.0/24"
}

variable "AccessKeyID"{
    default = "AKIAZJPFZBWRHZHSBRNU"
}

variable "SecretAccessKey"{
    default = "V4qqJZ47DDCFSbxVotmwr51MmuOir4sKCQseRS/C"
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

variable "Blue_count" {

    default = 2
}

variable "Green_count" {

    default = 2
}

output ALB{
    value = aws_lb.ALB.dns_name
   
}

output Blueinstances{

    
    value= aws_instance.instanceBlue[*].public_ip
}

output Greeninstances{

    value= aws_instance.instanceGreen[*].public_ip
}
