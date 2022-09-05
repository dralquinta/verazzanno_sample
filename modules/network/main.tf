locals {
    sl_tcp_public = [        
        {
            source = var.sb_pv_cidr
            min = 12250
            max = 12250
        },
        {
            source = var.sb_pb_cidr
            min = 12250
            max = 12250
        },
        {
            source = "0.0.0.0/0"
            min = 6443
            max = 6443
        }
    ]
}

# VCN CREATION

resource "oci_core_vcn" "vcn_for_oke" {
    #Required
    compartment_id = var.compartment_id
    cidr_block = var.vcn_cidr_block
    display_name = var.vcn_display_name
    freeform_tags = {"use"= "Demo"}
    dns_label = "okevcn"
    # vcn_domain_name = "okevcn.oraclevcn.com"
}

# SUBNET CREATION

resource "oci_core_subnet" "oke_pb_subnet" {
    #Required
    cidr_block = var.sb_pb_cidr
    compartment_id = var.compartment_id
    vcn_id = oci_core_vcn.vcn_for_oke.id
    dns_label = "pb"

    #Optional
    prohibit_internet_ingress = var.pb_inet_blocked
    prohibit_public_ip_on_vnic = var.pb_no_public_ip
    display_name = var.sb_pb_name
    route_table_id = oci_core_route_table.rt_public.id
    security_list_ids = [oci_core_security_list.pb_security_list.id]
}

resource "oci_core_subnet" "oke_pv_subnet" {
    #Required
    cidr_block = var.sb_pv_cidr
    compartment_id = var.compartment_id
    vcn_id = oci_core_vcn.vcn_for_oke.id
    dns_label = "pv"

    #Optional
    display_name = var.sb_pv_name
    prohibit_internet_ingress = var.pv_inet_blocked
    prohibit_public_ip_on_vnic = var.pv_no_public_ip
    route_table_id = oci_core_route_table.rt_private.id
    security_list_ids = [oci_core_security_list.pv_security_list.id]
}

# ROUTE TABLES

resource "oci_core_route_table" "rt_public" {
    #Required
    compartment_id = var.compartment_id
    vcn_id = oci_core_vcn.vcn_for_oke.id

    #Optional
    display_name = "rt_public"
    # dynamic
    route_rules {
            description = var.dg_rt_public.description
            destination =  var.dg_rt_public.destination
            network_entity_id = oci_core_internet_gateway.igw.id
        }
        depends_on = [ oci_core_internet_gateway.igw ]
    }



resource "oci_core_route_table" "rt_private" {
    #Required
    compartment_id = var.compartment_id
    vcn_id = oci_core_vcn.vcn_for_oke.id

    #Optional
    display_name = "rt_private"
    # dynamic
    route_rules {
            description = var.dg_rt_private.description
            destination =  var.dg_rt_private.destination
            network_entity_id = oci_core_nat_gateway.nat_gw.id
        }
        depends_on = [ oci_core_nat_gateway.nat_gw ]
    }


# IGW

resource "oci_core_internet_gateway" "igw" {
    #Required
    compartment_id = var.compartment_id
    vcn_id = oci_core_vcn.vcn_for_oke.id

    #Optional
    display_name = var.igw_name
}

resource "oci_core_nat_gateway" "nat_gw" {
    #Required
    compartment_id = var.compartment_id
    vcn_id = oci_core_vcn.vcn_for_oke.id
    #Optional
    #block_traffic = var.nat_gateway_block_traffic
    display_name = "nat_gw"
    #route_table_id = oci_core_route_table.rt_private.id
}

# SECURITY LISTS CREATION

resource "oci_core_security_list" "pb_security_list" {
    #Required
    compartment_id = var.compartment_id
    vcn_id = oci_core_vcn.vcn_for_oke.id

    display_name = "sl_pb"
    dynamic "ingress_security_rules" {
        for_each = local.sl_tcp_public
        content {
        protocol = 6
        source = ingress_security_rules.value["source"] == null ? var.sb_pb_cidr : ingress_security_rules.value["source"]
        #Required
        tcp_options {
                max = ingress_security_rules.value["max"]
                min = ingress_security_rules.value["min"]
            }
        }
    }
    dynamic "ingress_security_rules" {
        for_each = var.sl_icmp_public
        content {
            protocol = 1
            source = var.sb_pv_cidr
            icmp_options {
                #Required
                type = ingress_security_rules.value["type"]
            }
        }
    }
 egress_security_rules {
        #Required
        destination = "0.0.0.0/0"
        protocol = "all"
        }
}

resource "oci_core_security_list" "pv_security_list" {
    #Required
    compartment_id = var.compartment_id
    vcn_id = oci_core_vcn.vcn_for_oke.id

    display_name = "sl_pv"
    ingress_security_rules {
        protocol = "all"
        source = "0.0.0.0/0"
        }
 egress_security_rules {
        #Required
        destination = "0.0.0.0/0"
        protocol = "all"
        }
    }


/*
    ingress_security_rules {
        protocol = var.security_list_ingress_security_rules_protocol
        source = var.security_list_ingress_security_rules_source
        description = var.security_list_ingress_security_rules_description
        icmp_options {
            type = var.security_list_ingress_security_rules_icmp_options_type
        }
        */