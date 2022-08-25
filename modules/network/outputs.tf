output "vcn_id" {
  description = "The ID of the VCN"
  value       = oci_core_vcn.vcn_for_oke.id
}

output "sb_pb_id" {
  description = "The ID of the Public subnet"
  value       = oci_core_subnet.oke_pb_subnet.id
}

output "sb_pv_id" {
  description = "The ID of the Private subnet"
  value       = oci_core_subnet.oke_pv_subnet.id
}