resource "aws_security_group" "kinesis-host-sg" {

  name        = "${var.environment}-kinesis-host-sg"
  description = "kinesis host security group"

  dynamic "ingress" {
    for_each = var.sg_ports
    iterator = port
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"] //change it to your machine IP or bastion Host for security
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
