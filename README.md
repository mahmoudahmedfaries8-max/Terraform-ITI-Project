# Terraform AWS Project

## Prerequisites
- Terraform installed (v1.5+ recommended)
- AWS CLI configured with proper credentials
- Key pair file `fares_key.pem` in the project root
- Python 3 installed locally if you want to run scripts before deployment

## Description
This project deploys a VPC with:
- 2 Public Subnets → EC2 instances as Nginx Reverse Proxy
- 2 Private Subnets → EC2 instances as Web Application Backends
- NAT Gateway + Internet Gateway
- 2 Load Balancers:
  - Public ALB → directs traffic to proxies
  - Internal ALB → directs traffic from proxies to backend servers

## Steps to Run

1. Initialize Terraform
```bash
terraform init
```

2. Create and select workspace
```bash
terraform workspace new dev
terraform workspace select dev
```

3. Plan and apply
```bash
terraform plan -out=tfplan
terraform apply tfplan
```

## SSH Access
- Public EC2:
```bash
ssh -i fares_key.pem ec2-user@<public-ip>
```

- Private EC2s: Access via bastion host (first public EC2)

## Project Structure
## Project Structure
```text
terraform-project/
├── main.tf             # Root Terraform configuration
├── variables.tf        # Root variables
├── outputs.tf          # Root outputs
├── modules/
│   ├── vpc/
│   │   └── main.tf
│   ├── ec2/
│   │   └── main.tf
│   └── alb/
│       └── main.tf
├── app/
│   └── app.py          # Web application for private EC2s
├── images/             # Screenshots for documentation
│   ├── Apache Return.png
│   ├── Configuration of the proxy (Apache).png
│   ├── load Balancer DNS.png
│   ├── public server(proxy).png
│   ├── Screenshot 2025-11-08 224830.png
│   ├── S3 bucket containing the state file.png
│   └── workspace dev.png
└── key.pem             # SSH key pair for EC2 access

## Notes
- Application files for private EC2s are located in `app/`
- Outputs with all IPs will be printed in `all-ips.txt`
- Make sure security groups allow SSH and HTTP access
> **AWS Academy Restrictions:**  
> AWS Academy Learner Labs may restrict the number of EC2 instances you can launch.  
> This project requires **4 EC2 instances** (2 public + 2 private) and **2 ALBs**,  
> so it may **not fully work** in AWS Academy environment.  
> For full functionality, use a standard AWS account with enough EC2 and ALB quotas.


## Project Screenshots

```
<img width="1507" height="895" alt="TERAFORM" src="https://github.com/user-attachments/assets/5df2e21e-c037-4d48-8b94-61d943d01344" />

![dev](https://github.com/user-attachments/assets/3830b10f-78f4-4bf4-a6b6-f15b847acec9)



<img width="1920" height="818" alt="subnets" src="https://github.com/user-attachments/assets/b9a13dbc-d4a2-42a4-b337-15856d011341" />

<img width="1920" height="897" alt="instance" src="https://github.com/user-attachments/assets/987748cf-6769-4dc3-8c29-1f74bd2f2230" />

<img width="1500" height="746" alt="image" src="https://github.com/user-
attachments/assets/9489d1d0-13a3-420e-872f-af1b9e297ff6" />

<img width="1500" height="746" alt="image" src="https://github.com/user-attachments/assets/5761abdc-9c48-44c3-a136-7b67dd471529" />

<img width="1917" height="942" alt="apache" src="https://github.com/user-attachments/assets/3ef1e9f8-b102-4c62-bd9a-cebc07190f02" />










