
provider "azurerm" {
  features {}
}

resource "aws_security_group_rule" "my-rule" {
    type              = "ingress"
    protocol          = "tcp"
    from_port         = 0
    to_port           = 65535
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = "sg-123456"
}

resource "aws_lb" "front_end" {
}

resource "aws_alb_listener" "my-alb-listener"{
    load_balancer_arn = aws_lb.front_end.arn
    port     = "80"
    protocol = "HTTP"

    default_action {
        type             = "forward"
        #target_group_arn = aws_lb_target_group.front_end.arn
    }
}

resource "azurerm_resource_group" "example" {
    name                 = "example-group"
    location             = "East US"
}


resource "azurerm_managed_disk" "source" {
    name                 = "acctestmd"
    location             = azurerm_resource_group.example.location
    resource_group_name  = azurerm_resource_group.example.name
    storage_account_type = "Standard_LRS"
    create_option        = "Empty"

    disk_size_gb         = "1"

    #encryption_settings {
        #enabled = false
    #}

    tags = {
      environment = "staging"
    }
}
