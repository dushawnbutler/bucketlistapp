provider "aws" {
    region = "us-east-2"
}

# Declare the github_access_token variable
variable "github_access_token" {
    description = "GitHub personal access token for accessing the repository"
    type        = string
    sensitive   = true # Mark as sensitive to avoid displaying in logs
}

resource "aws_amplify_app" "bucketlistapp" {
    name       = "bucketlistapp"
    repository = "https://github.com/dushawnbutler/bucketlistapp.git"
    access_token = var.github_access_token # Reference the declared variable

    build_spec = <<-EOT
    version: 0.1
    frontend:
        phases:
        preBuild:
            commands:
            - yarn install
        build:
            commands:
            - yarn run build
        artifacts:
        baseDirectory: build
        files:
            - '**/*'
        cache:
        paths:
            - node_modules/**/*
    EOT

    custom_rule {
    source = "/<*>"
    status = "404"
    target = "/index.html"
    }

    environment_variables = {
    ENV = "test"
    }
}

# Configure the default branch (e.g., main) for the Amplify app
resource "aws_amplify_branch" "main" {
    app_id      = aws_amplify_app.bucketlistapp.id
    branch_name = "main" # Adjust to your repository's default branch (e.g., master if applicable)
}
