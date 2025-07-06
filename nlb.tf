resource "aws_lb" "vault_nlb" {
  name               = "vault-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets = [
    "subnet-0f6709602b301aa95",
    "subnet-0e2be7faaf7472165"
  ]
}

resource "aws_lb_target_group" "vault_tg" {
  name        = "vault-tg"
  port        = 8200
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "instance"
}

resource "aws_lb_listener" "vault_listener" {
  load_balancer_arn = aws_lb.vault_nlb.arn
  port              = 8200
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vault_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "vault_tg_attachment" {
  count            = aws_instance.vault.*.id != [] ? length(aws_instance.vault) : 0
  target_group_arn = aws_lb_target_group.vault_tg.arn
  target_id        = aws_instance.vault[count.index].id
  port             = 8200
}
