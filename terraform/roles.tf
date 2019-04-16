resource "aws_iam_policy" "ssm_policy" {
  name        = "ssm_policy"
  path        = "/"
  description = "SSM policy with EC2"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "ec2:CreateTags",
            "Resource": "arn:aws:ec2:*::snapshot/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstances",
                "ec2:CreateSnapshot"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "ssm:SendCommand",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role" "ssm_vss_role" {
  name = "ssm_vss_role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {"AWS": "*"},
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_policy_1" {
  role       = "${aws_iam_role.ssm_vss_role.name}"
  policy_arn = "${aws_iam_policy.ssm_policy.arn}"
}

resource "aws_iam_role_policy_attachment" "attach_policy_2" {
  role       = "${aws_iam_role.ssm_vss_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name  = "ssm_profile"
  role = "${aws_iam_role.ssm_vss_role.name}"
}
