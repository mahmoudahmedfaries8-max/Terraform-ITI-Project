output "all_ips" {
  value = concat(
    [for i, ip in module.public_ec2.public_ips : "public-ip${i + 1} ${ip}"],
    [for i, ip in module.private_ec2.private_ips : "private-ip${i + 1} ${ip}"]
  )
}

resource "null_resource" "write_ips" {
  triggers = { always_run = timestamp() }

  provisioner "local-exec" {
    command = <<EOT
echo "${join("\n", concat(
    [for i, ip in module.public_ec2.public_ips : "public-ip${i + 1} ${ip}"],
    [for i, ip in module.private_ec2.private_ips : "private-ip${i + 1} ${ip}"]
))}" > all-ips.txt
EOT
  }
}
