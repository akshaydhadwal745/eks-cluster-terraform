resource "aws_iam_role" "role_with_secrets_and_ssm" {
  name = "role-with-secretsmanager-and-ssm"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.role_with_secrets_and_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "instance-profile-admin-access"
  role = aws_iam_role.role_with_secrets_and_ssm.name
}