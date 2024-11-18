
# Create Route Table for the Public Subnet (Internet access)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
