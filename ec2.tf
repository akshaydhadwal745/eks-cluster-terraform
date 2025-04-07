# Create a security group
resource "aws_security_group" "main_instance_sg" {
  name_prefix = "instance-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Create a Key_pair for SSH
resource "aws_key_pair" "my_key" {
  key_name   = "my-ed25519-key"
  public_key = file("~/.ssh/id_ed25519.pub")
}

# Create an EC2 instance
resource "aws_instance" "main_instance" {
  ami           = "ami-0e35ddab05955cf57" # Ubuntu AMI (update as needed)
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name
  key_name      = aws_key_pair.my_key.key_name
  vpc_security_group_ids = [aws_security_group.main_instance_sg.id]
  root_block_device {
    volume_size = 10
    volume_type = "gp3"
    delete_on_termination = true
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              snap install aws-cli --classic
              curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
              chmod 777 kubectl
              mv kubectl /usr/bin
              aws eks --region ap-south-1 update-kubeconfig --name EKS-test
              EOF
  
  tags = {
    Name = "Main Instance"
  }
  depends_on = [ aws_eks_cluster.eks ]
}