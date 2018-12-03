provider "aws" {
  region = "eu-central-1"
}

// Some local variables
locals {
  subnet_count = 4
  subnet_size  = 16
  # IPs per subnet = subnet_size - 5; 
  # Thus available IPs: 11
  
  dividor      = 2
  generic_tag = "${var.owner}-${terraform.workspace}"
  azs = "${list("eu-central-1a", "eu-central-1b")}"
  public_subnet_count = "${local.subnet_count / local.dividor}"
  private_subnet_count = "${local.subnet_count / local.dividor}"
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
  count      = "${local.subnet_count}"
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.0.0.${count.index * local.subnet_size}/28"
  map_public_ip_on_launch = true
  availability_zone = "${element("${local.azs}", "${count.index}")}"

  tags {
    Name = "public-${local.generic_tag}-${count.index}"
  }
}

// resource "aws_subnet" "private" {
//   count      = "${local.private_subnet_count}"
//   vpc_id     = "${aws_vpc.main.id}"
//   cidr_block = "10.0.0.${count.index * local.subnet_size + local.dividor}/28"
//   map_public_ip_on_launch = false
//   availability_zone = "${element("${local.azs}", "${count.index}")}"

//   tags {
//     Name = "private-${local.generic_tag}-${count.index - 1}"
//   }
// }

resource "aws_eip" "nat" {
  vpc = true

  tags {
    Name = "${local.generic_tag}"
  }
}

resource "aws_nat_gateway" "gw" {
  // count = 2
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.public.0.id}"

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

resource "aws_route" "r" {
  route_table_id = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id         = "${aws_internet_gateway.igw.id}"
}

resource "aws_route_table_association" "a" {
  subnet_id      = "${aws_subnet.public.2.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "b" {
  subnet_id      = "${aws_subnet.public.3.id}"
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

resource "aws_route" "c" {
  route_table_id = "${aws_route_table.private.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id             = "${aws_nat_gateway.gw.id}"
}

resource "aws_route_table_association" "c" {
  subnet_id      = "${aws_subnet.public.0.id}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_route_table_association" "d" {
  subnet_id      = "${aws_subnet.public.1.id}"
  route_table_id = "${aws_route_table.private.id}"
}

