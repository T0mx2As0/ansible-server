module "Ansible" {
    source = "./modules/ansible"

    key_name = var.key_name
    instance_type = var.instance_type
}