# Chain of trust: internet -> web -> app -> db.
# Each tier only accepts traffic from the tier directly above it.

# ---------------------------------------------------------------------------
# Web tier
# ---------------------------------------------------------------------------
resource "aws_security_group" "web" {
  name_prefix = "${var.name}-web-"
  description = "Web tier: HTTP and HTTPS from allowed CIDR ranges"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name}-web-sg"
    Tier = "web"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "web_http" {
  for_each = toset(var.allowed_http_cidrs)

  security_group_id = aws_security_group.web.id
  description       = "HTTP from ${each.value}"
  cidr_ipv4         = each.value
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "web_https" {
  for_each = toset(var.allowed_http_cidrs)

  security_group_id = aws_security_group.web.id
  description       = "HTTPS from ${each.value}"
  cidr_ipv4         = each.value
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "web_all" {
  security_group_id = aws_security_group.web.id
  description       = "All outbound traffic"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# ---------------------------------------------------------------------------
# App tier
# ---------------------------------------------------------------------------
resource "aws_security_group" "app" {
  name_prefix = "${var.name}-app-"
  description = "App tier: accepts traffic from the web tier only"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name}-app-sg"
    Tier = "app"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "app_from_web" {
  security_group_id            = aws_security_group.app.id
  description                  = "App port from the web tier"
  referenced_security_group_id = aws_security_group.web.id
  from_port                    = var.app_port
  to_port                      = var.app_port
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "app_all" {
  security_group_id = aws_security_group.app.id
  description       = "All outbound traffic"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# ---------------------------------------------------------------------------
# Data tier: no egress rules, so it can only answer connections from the app tier
# ---------------------------------------------------------------------------
resource "aws_security_group" "db" {
  name_prefix = "${var.name}-db-"
  description = "Data tier: accepts traffic from the app tier only"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name}-db-sg"
    Tier = "data"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "db_from_app" {
  security_group_id            = aws_security_group.db.id
  description                  = "Database port from the app tier"
  referenced_security_group_id = aws_security_group.app.id
  from_port                    = var.db_port
  to_port                      = var.db_port
  ip_protocol                  = "tcp"
}
