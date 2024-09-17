# HelloWorddy_Localstack

In my project, I use Terraform to work with both LocalStack and AWS. Testing on AWS was time-consuming and expensive. That's why I started using LocalStack. LocalStack mimics AWS services locally, providing agility and cost savings. After testing my code on LocalStack, I could seamlessly transition to AWS. This method enhanced my development process with both time efficiency and cost-effectiveness.

This project uses LocalStack, Terraform, AWS services, and Kubernetes to build and manage cloud infrastructure.

# Diagram

![Diagram!](/public/diagram.png)


# Technologies Used
LocalStack: For simulating AWS services locally and testing.
Terraform: For managing and automating infrastructure as code.
AWS Services: For running the project in the cloud.
Kubernetes: For container management and orchestration.

# Setup and Running

LocalStack Setup:

```
docker-compose up
```

Terraform Setup:

```
terraform init
terraform apply
```

AWS Services:

Use AWS CLI or SDK to create and manage necessary services.

Kubernetes:

Create a Kubernetes cluster and deploy applications:

```
kubectl apply -f deployment.yml
kubectl apply -f service.yml
```

# Why These Technologies?
LocalStack: Provides agility and cost savings during development and testing.
Terraform: Ensures infrastructure is managed as code for consistency and automation.
AWS Services: Offers reliable and scalable cloud solutions.
Kubernetes: Manages containerized applications and orchestration effectively.

