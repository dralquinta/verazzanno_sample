# VCN

variable compartment_id {}
variable vcn_cidr_block { default = "10.0.0.0/16"}
variable vcn_display_name { default = "vcn_demo"}

# SUBNETS

variable sb_pb_name { default = "oke_public_subnet" }
variable sb_pv_name { default = "oke_private_subnet"}
variable sb_pb_cidr { default = "10.0.0.0/24" }
variable sb_pv_cidr { default = "10.0.1.0/24" }
variable pb_inet_blocked {}
variable pb_no_public_ip  {}
variable pv_inet_blocked {}
variable pv_no_public_ip  {}
variable igw_name {}

# ROUTE TABLES

variable dg_rt_public {}
variable dg_rt_private {}

# SECURITY LISTS

#variable sl_tcp_public {}
variable sl_icmp_public {}