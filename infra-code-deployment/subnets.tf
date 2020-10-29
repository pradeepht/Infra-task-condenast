resource "aws_default_vpc" "default_vpc" {
}

# Providing a reference to default subnets
resource "aws_default_subnet" "default_subnet_a" {
    availability_zone = "ap-south-1a"
}

resource "aws_default_subnet" "default_subnet_b" {
    availability_zone = "ap-south-1b"
}

resource "aws_default_subnet" "default_subnet_c" {
    availability_zone = "ap-south-1c"
}
