provider "aws" {
  region = "${var.region}"
}

# Some local variables
locals {
  generic_tag = "${var.owner}-${terraform.workspace}"

  # Public and private subnet count for frontend, app and data tiers
  public_subnet_count     = 2
  private_subnet_count    = 2
  private_db_subnet_count = 2

  # We'll be using only "a" and "b" AZs for target region
  azs = "${list("${var.region}a", "${var.region}b")}"
}

// A slice of network for each participant
resource "aws_vpc" "main" {
  cidr_block = "${var.network}"

  tags {
    Name = "${local.generic_tag}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "${local.generic_tag}"
  }
}

// Public type subnets for LB
resource "aws_subnet" "public" {
  count                   = "${local.public_subnet_count}"
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${cidrsubnet("${var.network}", "${var.subnet_bits}", count.index)}"
  map_public_ip_on_launch = true
  availability_zone       = "${element("${local.azs}", "${count.index}")}"

  tags {
    Name = "public-${local.generic_tag}-${count.index}"
  }
}

// Private type subnets for compute
resource "aws_subnet" "private" {
  count                   = "${local.private_subnet_count}"
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${cidrsubnet("${var.network}", "${var.subnet_bits}", count.index + 2)}"
  map_public_ip_on_launch = false
  availability_zone       = "${element("${local.azs}", "${count.index}")}"

  tags {
    Name = "private-compute-${local.generic_tag}-${count.index}"
  }
}

resource "aws_eip" "nat" {
  count = "${local.public_subnet_count}"
  vpc   = true

  tags {
    Name = "${local.generic_tag}"
  }
}

resource "aws_nat_gateway" "ngw" {
  count         = "${local.public_subnet_count}"
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"

  tags {
    Name = "${local.generic_tag}-${count.index}"
  }
}

//-----------------------------------------
// Public subnet routing 
//-----------------------------------------
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "public-${local.generic_tag}"
  }
}

resource "aws_route" "public" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.igw.id}"
}

resource "aws_route_table_association" "public_subn" {
  count          = "${local.public_subnet_count}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

//-----------------------------------------
// Private subnet routing
//-----------------------------------------
resource "aws_route_table" "private" {
  count  = "${local.private_subnet_count}"
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "private-${local.generic_tag}-${count.index}"
  }
}

resource "aws_route" "private" {
  count                  = "${local.private_subnet_count}"
  route_table_id         = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.ngw.*.id, count.index)}"
}

resource "aws_route_table_association" "private_subn" {
  count          = "${local.private_subnet_count}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}
