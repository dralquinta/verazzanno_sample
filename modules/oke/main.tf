resource "oci_containerengine_cluster" "oke" {
    count = 2
    #Required
    compartment_id = var.compartment_id
    kubernetes_version = var.cluster_kubernetes_version
    name = join("-", ["demo-verrazzano", count.index])
    vcn_id = var.vcn_for_oke

    #Optional
    cluster_pod_network_options {
        #Required
        cni_type = "FLANNEL_OVERLAY"
    }
    endpoint_config {

        #Optional
        is_public_ip_enabled = true
        subnet_id = var.oke_pb_subnet_id
    }
    #kms_key_id = oci_kms_key.test_key.id
    options {

        #Optional
        add_ons {

            #Optional
            is_kubernetes_dashboard_enabled = true
            is_tiller_enabled = true
        }
        service_lb_subnet_ids = [ var.oke_pb_subnet_id ]
    }
}

# NODEPOOLS

resource "oci_containerengine_node_pool" "oke_node_pool" {
    count = 2
    #Required
    cluster_id = oci_containerengine_cluster.oke[count.index].id
    compartment_id = var.compartment_id
    name = join("-", ["nodepool-cluster", tostring(count.index)])
    #node_shape = "VM.Standard3.Flex"
    node_shape = lookup(var.node_shape, "shape", "VM.Standard4.Flex")

    #Optional

    kubernetes_version = var.cluster_kubernetes_version
    node_config_details {
        #Required
        placement_configs {
            #Required
            availability_domain = var.np_ad
            subnet_id = var.oke_pv_subnet_id
        }
        size = var.node_count
        node_pool_pod_network_option_details {
            #Required
            cni_type = "FLANNEL_OVERLAY"
        }
    }

    node_shape_config {

        #Optional
        memory_in_gbs = lookup(var.node_shape, "memory", 10)
        ocpus = lookup(var.node_shape, "ocpu", 1)
    }
    node_source_details {
        #Required
        image_id = var.node_image
        source_type = data.oci_containerengine_node_pool_option.node_pool_option.sources[0].source_type
    }
    #subnet_ids = [ var.oke_pv_subnet_id ]
}