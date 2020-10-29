# Infra-task-condenast
This project contains the code to deploy containerised (docker) node app to AWS. For Infrastructure as code, have used terraform and for container orchestration, have used ECS with fargate launch type and Load balanced containers with ALB.

I have logically divided the code into two.

1. ECR creation and Pushing the Docker image
2. Building the infra necessary for running the container

In a real world projects, we can build 2 separate pipelines with this isolation.

### ECR creation and Pushing the Docker image

In the root directory perform the below:

```bash
terraform init 

export AWS_ACCESS_KEY_ID="XXXXXXXXXX" 
export AWS_SECRET_ACCESS_KEY="XXXXXXXXXXXXX" 

terraform apply 
```
This operation creates ECR repo on the account we authenticated.

Now, login to the AWS console and then navigate to the AWS ECR service, you should see newly created repository. Click on the repository and click View push commands. A modal will appear with four commands and those needs be run locally in order to have the image pushed up to the repository. 


### Building the infra necessary for running the container:

Navigate to folder infra-task-condenast

```bash
cd infra-task-condenast
```

Execute the below commands:

```bash
terraform init
terraform apply 
```
After terraform apply completes, It would have created 

```bash
an AWS ECS cluster 
an AWS ECS task
an AWS ECS service
a load balancer
```

Now, we can access the containers through load balancer URL and it should display "Hello World!"
