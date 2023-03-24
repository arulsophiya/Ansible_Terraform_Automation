output "webserver_ip" {
  value = aws_instance.web.public_ip
}

output "webserver_dns" {
  value = aws_instance.web.public_dns
}

output "web_key_pair" {
  value = data.aws_key_pair.web_key_pair.key_name
}

data "template_file" "ansible_inventory" {
  template = file("inventory.tpl")
  vars = {
    webserver-dns = aws_instance.web.public_dns
    webserver-ip  = aws_instance.web.public_ip
    ssh_user      = var.ssh_user_name
  }
}

resource "local_file" "ansible_inventory" {
  content  = data.template_file.ansible_inventory.rendered
  filename = "../ansible/inventory"
}
