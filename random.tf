resource "random_password" "aurora_password" {
  count   = var.generate_password == true ? 1 : 0
  length  = 10
  special = true
}
