module "network" {
  source = "./modules/network"
  compartment_id = var.compartment_id
  sb_pb_name = var.sb_pb_name
  sb_pv_name = var.sb_pv_name
  pb_inet_blocked = var.pb_inet_blocked
  pb_no_public_ip = var.pb_no_public_ip
  pv_inet_blocked = var.pv_inet_blocked
  pv_no_public_ip = var.pv_no_public_ip
  igw_name = var.igw_name
  dg_rt_public = var.dg_rt_public
  dg_rt_private = var.dg_rt_private
  sl_icmp_public = var.sl_icmp_public
}

module "oke" {
  source = "./modules/oke"
  compartment_id = var.compartment_id
  cluster_kubernetes_version = "v1.23.4"         
  oke_pb_subnet_id = module.network.sb_pb_id
  oke_pv_subnet_id = module.network.sb_pv_id
  vcn_for_oke = module.network.vcn_id
  cluster_count = var.cluster_count
  np_ad = var.np_ad
  node_image = var.node_image
  node_count = var.node_count
  node_shape = var.node_shape
  depends_on = [ module.network ]
}