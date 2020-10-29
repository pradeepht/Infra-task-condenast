provider "aws" {
    version = "~> 2.0"
    region  = "ap-south-1"
}

resource "aws_ecs_cluster" "node_app_cluster" {
    name = "node-app-cluster"
}

resource "aws_ecs_task_definition" "node_app_task" {
    family                   = "node-app-task"
    container_definitions    = <<DEFINITION
  [
    {
      "name": "node-app-task",
      "image": "${data.aws_ecr_repository.node_app_ecr_repo.repository_url}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 3000,
          "hostPort": 3000
        }
      ],
      "memory": 512,
      "cpu": 256
    }
  ]
  DEFINITION
    requires_compatibilities = ["FARGATE"]
    network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
    memory                   = 512
    cpu                      = 256
    execution_role_arn       = "${aws_iam_role.ecsTaskExecutionRole.arn}"
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
    name               = "ecsTaskExecutionRole"
    assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}

data "aws_iam_policy_document" "assume_role_policy" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
            type        = "Service"
            identifiers = ["ecs-tasks.amazonaws.com"]
        }
    }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
    role       = "${aws_iam_role.ecsTaskExecutionRole.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_service" "node_app_service" {
    name            = "node-app-service"
    cluster         = "${aws_ecs_cluster.node_app_cluster.id}"
    task_definition = "${aws_ecs_task_definition.node_app_task.arn}"
    launch_type     = "FARGATE"
    desired_count   = 3 # Setting the number of containers we want to deploy
    depends_on      = [ "aws_alb.application_load_balancer", "aws_lb_target_group.target_group", "aws_lb_listener.listener" ] # Wait until these resources are created

    network_configuration {
        subnets          = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}", "${aws_default_subnet.default_subnet_c.id}"]
        assign_public_ip = true
        security_groups  = ["${aws_security_group.service_security_group.id}"]
    }

    load_balancer {
        target_group_arn = "${aws_lb_target_group.target_group.arn}"
        container_name   = "${aws_ecs_task_definition.node_app_task.family}"
        container_port   = 3000 # Specifying the container port
    }
}

resource "aws_security_group" "service_security_group" {
    ingress {
        from_port = 0
        to_port   = 0
        protocol  = "-1"
        security_groups = ["${aws_security_group.load_balancer_security_group.id}"]  # Only allowing traffic in from the load balancer security group
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

