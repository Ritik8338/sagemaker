provider "aws"{
    region = "us-west-2"
}

# Define variables
variable "image_repository_name" {
  description = "demorepo"
  type        = string
  default     = "my-container-repo"
}

variable "image_tag" {
  description = "Tag for the Docker image"
  type        = string
  default     = "latest"
}

resource "aws_ecr_repository" "noiselesstech" {
	  name = "noiselesstech"
	

	  image_scanning_configuration {
	    scan_on_push = true
	  }
}

resource "aws_ecr_lifecycle_policy" "default_policy" {
  repository = aws_ecr_repository.noiselesstech.name
	

	  policy = <<EOF
	{
	    "rules": [
	        {
	            "rulePriority": 1,
	            "description": "Keep only the last untagged images.",
	            "selection": {
	                "tagStatus": "untagged",
	                "countType": "imageCountMoreThan"
	            },
	            "action": {
	                "type": "expire"
	            }
	        }
	    ]
	}
	EOF
	

}


resource "null_resource" "docker_packaging" {
	
	  provisioner "local-exec" {
	    command = <<EOF
	    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 575773971780.dkr.ecr.us-west-2.amazonaws.com
	    gradle build -p noiselesstech
	    docker build -t "${aws_ecr_repository.noiselesstech.repository_url}:latest" -f noiselesstech/Dockerfile .
	    docker push "${aws_ecr_repository.noiselesstech.repository_url}:latest"
	    EOF
	  }
	

	  triggers = {
	    "run_at" = timestamp()
	  }
	

	  depends_on = [
	    aws_ecr_repository.noiselesstech,
	  ]
}



