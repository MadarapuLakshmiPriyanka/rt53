resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.eip.id
  subnet_id = aws_subnet.publicsubnet[0].id
  tags = {
    "Name" = "${var.vpc_name}-ngw"
  }
  depends_on = [ aws_internet_gateway.igw ]
}