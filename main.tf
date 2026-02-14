data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["bitnami-tomcat-*-x86_64-hvm-ebs-nami"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["979382823631"] # Bitnami
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.app_ami.id
  instance_type = var.instance_type

  tags = {
    Name = "HelloWorld"
  }
}

resource "aws_ses_email_identity" "example" {
  email = "bjameson@webddr.com"
}

action "aws_ses_send_email" "example" {
  config {
    source       = aws_ses_email_identity.example.email
    subject      = "Test Email"
    text_body    = "This is a test email sent from Terraform once the apply completes."
    to_addresses = ["brettwjameson@churchofjesuschrist.org"]
  }
}

resource "terraform_data" "example" {
  input = "send-notification"

  lifecycle {
    action_trigger {
      events  = [before_create, before_update]
      actions = [action.aws_ses_send_email.example]
    }
  }
}
