provider "oci" {
   region = "us-ashburn-1"
   alias = "ash"
   tenancy_ocid = "ladmcrs"
   user_ocid = "ocid1.user.oc1..aaaaaaaa6a5wwffkabvfh22q5mkxhdzjpuavxtzhg5mqjrzoepgpns7eccya"
   #fingerprint = "${var.fingerprint}"
   private_key_path = "/home/aguinez/.oci/oracleidentitycloudservice_alex.guinez-08-03-18-36.pem"
}