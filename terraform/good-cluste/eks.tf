

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.30.2"

  #cluster name
  cluster_name = var.cluster_name

  #network
  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = module.vpc.subnet_ids
  enable_irsa                     = true
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  #logs
  create_cloudwatch_log_group = false
  cluster_enabled_log_types   = []


  #addons
  cluster_addons = {
    aws-ebs-csi-driver = {
      resolve_conflicts        = "OVERWRITE"
      addon_version            = var.addon_version # Вкажіть правильну версію
      service_account_role_arn = module.irsa_ebs_csi_driver.iam_role_arn
    }
  }


  #addons
  tags = {
    "Name"            = var.cluster_name
    "Type"            = "Kubernetes Service"
    "K8s Description" = "Kubernetes for deployment related to ${var.deployment_prefix}"
  }



  #node group settings
  eks_managed_node_groups = {
    management = {
      #size
      min_size      = var.min_size
      max_size      = var.max_size
      desired_size  = var.desired_size
      capacity_type = "ON_DEMAND"

      #instance type
      instance_types = [var.instance_type]


    }
  }

  #security_groups
  node_security_group_additional_rules = {


    ingress_allow_access_from_control_plane = {
      description                   = "Allow workers pods to receive communication from the cluster control plane."
      type                          = "ingress"
      protocol                      = "tcp"
      from_port                     = 1025
      to_port                       = 65535
      source_cluster_security_group = true

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

