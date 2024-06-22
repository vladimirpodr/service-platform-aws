### Peering connections with SaaS platforms.

## Peering connection with Aiven Kafka VPC.

# Accepter's side.
resource "aws_vpc_peering_connection_accepter" "aiven_vpc_peer" {
  vpc_peering_connection_id = var.aiven_vpc_peering_connection_id
  auto_accept               = true

  tags = {
    Name = "${local.basename}-aiven-vpc-peering"
  }
}

### Peer Routing tables rule
resource "aws_route" "aiven_peer_pcx" {
  for_each = toset(module.vpc.rts_private)

  route_table_id = each.value

  destination_cidr_block    = var.aiven_vpc_cidr
  vpc_peering_connection_id = var.aiven_vpc_peering_connection_id

  depends_on = [aws_vpc_peering_connection_accepter.aiven_vpc_peer]
}

## Peering connection with Atlas MongoDB VPC.

# Accepter's side.
resource "aws_vpc_peering_connection_accepter" "atlas_vpc_peer" {
  vpc_peering_connection_id = var.atlas_vpc_peering_connection_id
  auto_accept               = true

  tags = {
    Name = "${local.basename}-atlas-vpc-peering"
  }
}

### Peer Routing tables rule
resource "aws_route" "atlas_peer_pcx" {
  for_each = toset(module.vpc.rts_private)

  route_table_id = each.value

  destination_cidr_block    = var.atlas_vpc_cidr
  vpc_peering_connection_id = var.atlas_vpc_peering_connection_id

  depends_on = [aws_vpc_peering_connection_accepter.atlas_vpc_peer]
}