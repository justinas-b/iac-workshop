provider "aws" {
  region = "${var.region}"
}

// Some local variables
locals {
  generic_tag  = "${var.owner}-${terraform.workspace}"
  subnet_count = 4

  # IPs per subnet = subnet_size - 5; 
  # Therefore actually available IPs: 11
  subnet_size = 16

  # Divisor for separating subnet types, e.g. public and private
  divisor = 2

  public_subnet_count  = "${local.subnet_count / local.divisor}"
  private_subnet_count = "${local.subnet_count / local.divisor}"

  # We'll be using only "a" and "b" AZs for target region
  azs = "${list("${var.region}a", "${var.region}b")}"
}

// A slice of network for each participant
resource "aws_vpc" "main" {
  # variable for participant: 10.0.0.0; 10.0.0.64; 10.0.0.128
  cidr_block = "10.0.0.0/26"

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

resource "aws_subnet" "public" {
  count                   = "${local.public_subnet_count}"
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "10.0.0.${count.index * local.subnet_size}/28"
  map_public_ip_on_launch = true
  availability_zone       = "${element("${local.azs}", "${count.index}")}"

  tags {
    Name = "public-${local.generic_tag}-${count.index}"
  }
}

resource "aws_subnet" "private" {
  count                   = "${local.private_subnet_count}"
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "10.0.0.${(count.index + local.divisor) * local.subnet_size }/28"
  map_public_ip_on_launch = false
  availability_zone       = "${element("${local.azs}", "${count.index}")}"

  tags {
    Name = "private-${local.generic_tag}-${count.index}"
  }
}

resource "aws_eip" "nat" {
  vpc = true

  tags {
    Name = "${local.generic_tag}"
  }
}

resource "aws_nat_gateway" "gw" {
  count = 2
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"

  tags {
    Name = "${local.generic_tag}"
  }

  depends_on = ["aws_internet_gateway.igw"]
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
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "private-${local.generic_tag}"
  }
}

resource "aws_route" "private" {
  route_table_id         = "${aws_route_table.private.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.gw.*.id}"
}

resource "aws_route_table_association" "private_subn" {
  count          = "${local.private_subnet_count}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
}
