
locals {
  cluster_name = "${var.deployment_prefix}-eks-cluster"
}

module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "18.30.2"
  cluster_name                    = local.cluster_name
  vpc_id                          = aws_vpc.my_vpc.id
  subnet_ids                      = [aws_subnet.public1a.id, aws_subnet.public2b.id]
  enable_irsa                     = true
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  create_cloudwatch_log_group = false
  cluster_enabled_log_types   = []

  cluster_addons = {
    aws-ebs-csi-driver = {
      resolve_conflicts        = "OVERWRITE"
      addon_version = "v1.39.0-eksbuild.1"  # Вкажіть правильну версію
      service_account_role_arn = module.irsa_ebs_csi_driver.iam_role_arn
    }
  }

  tags = {
    "Name"            = "${local.cluster_name}"
    "Type"            = "Kubernetes Service"
    "K8s Description" = "Kubernetes for deployment related to ${var.deployment_prefix}"
  }

  # EKS Managed Node Group(s)
  eks_managed_node_groups = {
    management = {
      min_size     = 2
      max_size     = 2
      desired_size = 2
      capacity_type  = "ON_DEMAND"

      instance_types = ["t3.medium"]

        
      }
    }
    node_security_group_additional_rules = {
    ingress_allow_access_from_control_plane = {
      type                          = "ingress"
      protocol                      = "tcp"
      from_port                     = 1025
      to_port                       = 65535
      source_cluster_security_group = true
      description                   = "Allow workers pods to receive communication from the cluster control plane."
    }
    ingress_self_all = {
      description = "Allow nodes to communicate with each other (all ports/protocols)."
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress."
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
    }

}

