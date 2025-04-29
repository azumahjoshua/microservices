resource "aws_iam_role" "this" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "this" {
  name = var.policy_name
  role = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # Read permissions (existing)
      {
        Effect    = "Allow",
        Action   = var.ecr_public_actions,
        Resource = "*"
      },
      # Write permissions (new)
      {
        Effect    = "Allow",
        Action   = [
          "ecr-public:InitiateLayerUpload",
          "ecr-public:UploadLayerPart",
          "ecr-public:CompleteLayerUpload",
          "ecr-public:PutImage",
          "ecr-public:BatchCheckLayerAvailability",
          "ecr-public:GetRepositoryPolicy",
          "ecr-public:DescribeRepositories",
          "ecr-public:CreateRepository"
        ],
        Resource = "*"
      },
      # STS token permission (required for ECR Public auth)
      {
        Effect    = "Allow",
        Action   = ["sts:GetServiceBearerToken"],
        Resource = "*",
        Condition = {
          StringEquals = {
            "aws:RequestedRegion" = "us-east-1"
          }
        }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.role_name}-instance-profile"
  role = aws_iam_role.this.name
}

