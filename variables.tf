variable "cluster_name" {
  default = "teste-inhml"
}

variable "aws_region" {
  default = "us-east-2"
}

variable "aws_account_id" {
  default = "123456789012"
}

variable "eks_role_external_dns" {
  default = "eks-role-external-dns"
}

variable "eks_domain_dns_url" {
  default = "eks-domain-dns-url"
}

variable "route53_zone_id" {
  default = "route53-zone-id"
}

variable "k8s_version" {
  default = "1.21"
}

variable "deploy_argocd" {
  default = true
}

variable "istio_version" {
  default = "1.9.1"
}

variable "nodes_instances_sizes" {
  default = [
    "t3.small"
  ]
}

variable "auto_scale_options" {
  default = {
    min     = 1
    max     = 1
    desired = 1
  }
}

variable "auto_scale_cpu" {
  default = {
    scale_up_threshold  = 80
    scale_up_period     = 60
    scale_up_evaluation = 2
    scale_up_cooldown   = 300
    scale_up_add        = 2

    scale_down_threshold  = 40
    scale_down_period     = 120
    scale_down_evaluation = 2
    scale_down_cooldown   = 300
    scale_down_remove     = -1
  }
}


# ARGO CD VARIABLES

variable "kubernetes_argocd_namespace" {
  description = "Namespace to release argocd into"
  type        = string
  default     = "argocd"
}

variable "argocd_helm_chart_version" {
  description = "argocd helm chart version to use"
  type        = string
  default     = ""
}