compartment_id = "ocid1.compartment.oc1..aaaaaaaarg5cvtvzvs47gsjh5kaabya5xltiwngnivl2hpauofpj52wetfxa"
# NETWORK MODULE
sb_pb_name = "sb_oke_public"
sb_pv_name = "sb_oke_private"
vcn_cidr_block = "10.0.0.0/16"
vcn_display_name = "vcn_demo"
pb_inet_blocked = false
pb_no_public_ip = false
pv_inet_blocked = true
pv_no_public_ip = true
igw_name = "igw" 
sb_pb_cidr = "10.0.0.0/24"
sb_pv_cidr = "10.0.1.0/24"

# OKE Module

np_ad = "EgzC:US-ASHBURN-AD-1"
node_image = "ocid1.image.oc1.iad.aaaaaaaammndnkjpb2fz5cjwpxhfthvx7wfcst2ihezze276lkei2cnon4vq"
cluster_count = 3
node_count = 2
node_shape = {
        shape = "VM.Standard3.Flex"
        ocpu = 2
        memory = 32
    }
#node_shape = "VM.Standard3.Flex"
#ocid1.image.oc1.iad.aaaaaaaadl5lond67wh3qx64qjpzh2apqmnranxaorhww3vlxxoipjqa53lq
#"Oracle-Linux-8.6-aarch64-2022.06.30-0-OKE-1.24.1-417"  