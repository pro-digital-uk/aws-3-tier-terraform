data "aws_ami" "al2023" {
  count = var.ami_id == null ? 1 : 0

  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

locals {
  ami_id = var.ami_id != null ? var.ami_id : data.aws_ami.al2023[0].id
}

# ---------------------------------------------------------------------------
# IAM: SSM Session Manager access (no SSH keys) and optional read-only S3 access
# ---------------------------------------------------------------------------
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "${var.name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy_document" "s3_read" {
  count = length(var.s3_bucket_arns) > 0 ? 1 : 0

  statement {
    actions   = ["s3:GetObject", "s3:ListBucket"]
    resources = flatten([for arn in var.s3_bucket_arns : [arn, "${arn}/*"]])
  }
}

resource "aws_iam_role_policy" "s3_read" {
  count = length(var.s3_bucket_arns) > 0 ? 1 : 0

  name   = "${var.name}-s3-read"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.s3_read[0].json
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.name}-profile"
  role = aws_iam_role.this.name

  tags = var.tags
}

# ---------------------------------------------------------------------------
# Instance
# ---------------------------------------------------------------------------
resource "aws_instance" "this" {
  ami                         = local.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = length(var.security_group_ids) > 0 ? var.security_group_ids : null
  associate_public_ip_address = var.associate_public_ip_address
  iam_instance_profile        = aws_iam_instance_profile.this.name
  user_data                   = var.user_data

  user_data_replace_on_change = true

  # IMDSv2 only: blocks the classic SSRF credential-theft path.
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = var.root_volume_size
    encrypted   = true
  }

  tags = merge(var.tags, { Name = var.name })

  lifecycle {
    # A newer "latest" AMI must not silently replace a running instance.
    ignore_changes = [ami]
  }
}
