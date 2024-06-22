resource "aws_route53_zone" "main" {
  for_each = toset(local.hosted_environments)

  name = "${each.key}.${var.root_domain}"
}

module "certificate" {
  source = "git@github.com:project/aws-terraform-modules.git//acm"

  for_each = toset(local.hosted_environments)

  name                      = "${local.basename}-${each.key}"
  domain_name               = "${each.key}.${var.root_domain}"
  subject_alternative_names = ["*.${each.key}.${var.root_domain}"]
  route53_zone_id           = aws_route53_zone.main[each.key].zone_id
}
