module "network" {
  source = "./modules/network"

  cluster_name = var.cluster_name
  aws_region   = var.aws_region
}

module "master" {
  source = "./modules/master"

  cluster_name = var.cluster_name
  aws_region   = var.aws_region
  k8s_version  = var.k8s_version

  cluster_vpc       = module.network.cluster_vpc
  private_subnet_1a = module.network.private_subnet_1a
  private_subnet_1b = module.network.private_subnet_1b
  private_subnet_1c = module.network.private_subnet_1c
}

module "nodes" {
  source = "./modules/nodes"

  cluster_name = var.cluster_name
  aws_region   = var.aws_region
  k8s_version  = var.k8s_version

  cluster_vpc       = module.network.cluster_vpc
  private_subnet_1a = module.network.private_subnet_1a
  private_subnet_1b = module.network.private_subnet_1b
  private_subnet_1c = module.network.private_subnet_1c

  eks_cluster    = module.master.eks_cluster
  eks_cluster_sg = module.master.security_group

  nodes_instances_sizes = var.nodes_instances_sizes
  auto_scale_options    = var.auto_scale_options

  auto_scale_cpu = var.auto_scale_cpu
}

module "external_dns" {
  source               = "git::https://github.com/rhythmictech/terraform-aws-eks-iam-external-dns"
  cluster_name         = local.eks_cluster.name
  issuer_url           = local.eks_cluster.identity[0].oidc[0].issuer
  service_account      = "external-dns"
  kubernetes_namespace = "default"
}

# module "external_dns_url_config" {
#   source = "./modules/external-dns"

#   aws_account_id        = var.aws_account_id
#   eks_role_external_dns = var.eks_role_external_dns
#   eks_domain_dns_url    = var.eks_domain_dns_url
#   route53_zone_id       = var.route53_zone_id
# }

module "argocd" {
  source = "./modules/argocd"
  count  = var.deploy_argocd ? 1 : 0

  depends_on = [
    module.network,
    module.nodes,
    module.master
  ]
}

resource "kubectl_manifest" "external_dns_service_account" {
  depends_on = [
    module.network,
    module.nodes,
    module.master,
    module.argocd
  ]

  namespace = "default"

  yaml_body = templatefile("${path.module}/modules/external-dns/serviceAccount.yaml", {
    role_arn = "arn:aws:iam::${var.aws_account_id}:role/${var.eks_role_external_dns}"
  })
}

resource "kubectl_manifest" "external_dns_cluster_role" {
  depends_on = [
    module.network,
    module.nodes,
    module.master,
    module.argocd
  ]

  namespace = "default"

  yaml_body = templatefile("${path.module}/modules/external-dns/clusterRole.yaml", {})
}

resource "kubectl_manifest" "external_dns_cluster_role_binding" {
  depends_on = [
    module.network,
    module.nodes,
    module.master,
    module.argocd
  ]

  namespace = "default"

  yaml_body = templatefile("${path.module}/modules/external-dns/clusterRoleBinding.yaml", {})
}

resource "kubectl_manifest" "external_dns_deployment" {
  depends_on = [
    module.network,
    module.nodes,
    module.master,
    module.argocd
  ]

  namespace = "default"

  yaml_body = templatefile("${path.module}/modules/external-dns/deployment.yaml", {
    role_arn        = "arn:aws:iam::${var.aws_account_id}:role/${var.eks_role_external_dns}"
    domain          = var.eks_domain_dns_url
    route53_zone_id = var.route53_zone_id
  })
}


#module "mesh" {
#  source = "./modules/mesh"
#  depends_on = [module.nodes]

#  cluster_name        = var.cluster_name
#  aws_region          = var.aws_region
#  k8s_version         = var.k8s_version
#  istio_version       = var.istio_version
#}

# get EKS cluster info to configure Kubernetes and Helm providers
data "aws_eks_cluster" "cluster" {
  name = module.master.eks_cluster.id
}
data "aws_eks_cluster_auth" "eks_cluster" {
  name = module.master.eks_cluster.id
}

# get EKS authentication for being able to manage k8s objects from terraform
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks_cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks_cluster.token
  }
}

provider "kubectl" {
  load_config_file       = false
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks_cluster.token
}
