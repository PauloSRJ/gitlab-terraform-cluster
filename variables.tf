variable "cluster_name" {
  default = "inhml"
}

variable "aws_region" {
  default = "us-east-2"
}

variable "k8s_version" {
  default = "1.21"
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
