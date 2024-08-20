
# We need to create cross account trust policy here. Document shown below.
# https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies-cross-account-resource-access.html

# Missing parts :
# Create an IAM role with a trust policy allowing Account B to assume it and a permissions policy granting ECR actions.

{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::Account2:root"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }

# Grant the IAM user the ability to assume the role in Account A.

  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ],
        "Resource": "arn:aws:ecr:<region>:Account1:repository/<your-repository>"
      }
    ]
  }
  
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": "sts:AssumeRole",
        "Resource": "arn:aws:iam::Account1:role/<Role-Name>"
      }
    ]
  }
  # Use get-login-password to authenticate the Docker client with ECR before pushing images.
  
  #aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin Account1.dkr.ecr.<region>.amazonaws.com

  #docker push Account1.dkr.ecr.<region>.amazonaws.com/<repository>:<tag>
