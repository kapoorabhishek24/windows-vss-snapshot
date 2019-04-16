resource "aws_ssm_maintenance_window" "window" {
  name     = "vss-snapshot"
  schedule = "rate(5 minutes)"
  duration = 3
  cutoff   = 1
}

resource "aws_ssm_maintenance_window_target" "target1" {
  window_id     = "${aws_ssm_maintenance_window.window.id}"
  resource_type = "INSTANCE"
  targets {
    key    = "InstanceIds"
    values = ["${aws_instance.windows-vss.id}"]
  }
}

resource "aws_ssm_maintenance_window_task" "task" {
  window_id        = "${aws_ssm_maintenance_window.window.id}"
  name             = "vss-ssm-task"
  description      = "This is a VSS Snapshot Task"
  task_type        = "RUN_COMMAND"
  task_arn         = "AWSEC2-CreateVssSnapshot"
  priority         = 1
  service_role_arn = "arn:aws:iam::ACCOUNT_ID:role/aws-service-role/ssm.amazonaws.com/AWSServiceRoleForAmazonSSM"
  max_concurrency  = "1"
  max_errors       = "1"

  targets {
    key    = "InstanceIds"
    values = ["${aws_instance.windows-vss.id}"]
  }

  task_parameters {
    name   = "ExcludeBootVolume"
    values = ["False"]
  }
}

resource "aws_instance" "windows-vss" {
   ami  = "${var.ami}"
   instance_type = "m5.large"
   subnet_id = "${var.public_subnet_id}"
   key_name = "Enter_Your_Key"
   iam_instance_profile = "${aws_iam_instance_profile.ssm_profile.name}"
   vpc_security_group_ids = ["${aws_security_group.sgwin.id}"]
   associate_public_ip_address = true
   source_dest_check = false
   user_data = "${file("../scripts/snapshot.txt")}"
  tags {
    Name = "poc-windows-vss"
  }
}

# Public Subnet Security Group
resource "aws_security_group" "sgwin" {
  name = "PublicSubnetWindows"
  description = "Allow Incoming RDP access"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port = 3389
    to_port = 3389
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 1433
    to_port = 1443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks =  ["0.0.0.0/0"]
  }
}
