output "vpc_id"{
    value = aws_vpc.test_vpc.id
}

# PUBLIC SUBNET IDS
output "public_subnet_id_1"{
    value = aws_subnet.public_subnet_1.id
}

output "public_subnet_id_2"{
    value = aws_subnet.public_subnet_2.id
}

# PRIVATE SUBNET APP TIER
output "private_subnet_id_1a"{
    value = aws_subnet.private_subnet_1a.id
}
output "private_subnet_id_1b"{
    value = aws_subnet.private_subnet_1b.id
}

# PRIVATE SUBNET DB TIER
output "private_subnet_id_2a"{
    value = aws_subnet.private_subnet_2a.id
}
output "private_subnet_id_2b"{
    value = aws_subnet.private_subnet_2b.id
}

