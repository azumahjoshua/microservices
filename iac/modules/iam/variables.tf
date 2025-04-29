variable "role_name" {
  description = "The name of the IAM role for Jenkins EC2"
  type        = string
}

variable "policy_name" {
  description = "The name of the IAM policy attached to the role"
  type        = string
}

variable "ecr_public_actions" {
  description = "List of ECR Public actions allowed"
  type        = list(string)
  default = [
    "ecr-public:GetAuthorizationToken",
    "ecr-public:BatchCheckLayerAvailability",
    "ecr-public:GetRepositoryCatalogData",
    "ecr-public:GetRepositoryPolicy",
    "ecr-public:DescribeRepositories",
    "ecr-public:DescribeImages",
    "ecr-public:GetDownloadUrlForLayer"
  ]
}
