data "aws_ami" "app_ami" {
  most_recent = true
  owners      = ["amazon"]


  filter {
    name   = "name"
    values = ["amzn-ami-hvm*"]
  }
}


resource "aws_instance" "kinesis-host-ec2" {
  tags = {
    name = "kinesis host instance"
  }


  ami                    = data.aws_ami.app_ami.id
  instance_type          = var.instance-type // give your respective size
  user_data              = file("kinesis-agent.sh")
  key_name               = "myfirstasgkeypair" //give your key-pair name for SSH
  vpc_security_group_ids = [aws_security_group.kinesis-host-sg.id]
  iam_instance_profile   = aws_iam_instance_profile.kinesis_host_profile.name

  depends_on = [aws_kinesis_firehose_delivery_stream.purchaselogs, aws_kinesis_stream.order_logs_stream]

}


resource "aws_iam_role" "kinesis_role" {
  name = "${var.environment}-kinesis_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy" "kinesis_role_policy" {
  name = "${var.environment}-kinesis_role_policy"
  role = aws_iam_role.kinesis_role.id

  policy = <<-EOF
{
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Action": "*",
              "Resource": "*"
          }
      ]
}
 EOF
}


resource "aws_iam_instance_profile" "kinesis_host_profile" {
  name = "${var.environment}-kinesis_host_profile"
  role = aws_iam_role.kinesis_role.name
}
