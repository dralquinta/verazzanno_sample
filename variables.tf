variable compartment_id {}
variable pb_inet_blocked {}
variable pb_no_public_ip  {}
variable pv_inet_blocked {}
variable pv_no_public_ip  {}
variable igw_name {}
variable sb_pv_cidr {}
variable sb_pb_cidr {}
variable sb_pb_name {}
variable sb_pv_name {}
variable cluster_count {}
variable "sl_icmp_public" {
  type = list(map(number))
  default = [        
        {
            type = 3
        },
        {
            type = 4
        }
    ]
}

variable "dg_rt_public" {
  type = map(string)
  default = {
            description = "Routes internal VCN"
            destination = "0.0.0.0/0"
        }
}

variable "dg_rt_private" {
  type = map(string)
  default = {
            description = "Routes internal VCN"
            destination = "0.0.0.0/0"
        }
}


# OKE

variable np_ad {}
variable node_image {}
variable node_count {}
variable node_shape {}