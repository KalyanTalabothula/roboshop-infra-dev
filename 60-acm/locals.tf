
locals {
        common_tags = {
        Project = var.project
        Environment = var.environment
        Terraform = "true"
    }
}

/*  📝 ACM Simple Note
ACM (AWS Certificate Manager) → Creates HTTPS/SSL certificates.
Needs only: domain_name + validation_method.
Does NOT need: vpc_id, subnet_ids, security_group_id → because ACM is not tied to networking.
Networking (VPC/Subnets/SG) → Needed only when attaching cert to Load Balancer / CloudFront.
Tags (common_tags) → You can add anywhere, good for tracking.

👉 Shortcut to remember:
“ACM = Certificate Only, Networking Later.” */