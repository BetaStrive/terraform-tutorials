resource "aws_instance" "app" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  iam_instance_profile = "EMR_EC2_DefaultRole"

  user_data = <<-EOF
                #!/bin/bash
                sudo dnf install python-pip
                sudo pip install boto3

                cat <<EOF > /home/ec2-user/dynamodb_reader.py
                import boto3

                dynamodb = boto3.resource('dynamodb')
                table = dynamodb.Table('example-table')

                response = table.get_item(
                    Key={
                        'ID': '1',
                        'Timestamp': 1
                    }
                )

                print(response['Item'])
              EOF

  tags = {
    Name = "EC2-DynamoDB-Reader"
  }
}