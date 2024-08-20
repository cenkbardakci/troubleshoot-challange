

{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::<Account-B-ID>:root"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }


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
        "Resource": "arn:aws:ecr:<region>:<Account-A-ID>:repository/<your-repository>"
      }
    ]
  }
  
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": "sts:AssumeRole",
        "Resource": "arn:aws:iam::<Account-A-ID>:role/<Role-Name>"
      }
    ]
  }
  

  #aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <account-A-id>.dkr.ecr.<region>.amazonaws.com

  #docker push <account-A-id>.dkr.ecr.<region>.amazonaws.com/<repository>:<tag>
