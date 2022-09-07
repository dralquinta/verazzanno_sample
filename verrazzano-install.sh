# Instalación operador de Verrazzano, versión 1.3.3 compatible con Kubernetes:1.21, 1.22, 1.23

clusters=$(oci ce cluster list -c "ocid1.compartment.oc1..aaaaaaaarg5cvtvzvs47gsjh5kaabya5xltiwngnivl2hpauofpj52wetfxa" | jq ".data[].id" | tail -3 | tr -d '"')
i=0

config(){
    if [[ "$1" == 0 ]]; then
        export META_NAME=master-verrazzano
        export PROFILE=dev
    else
        export META_NAME=managed-verrazzano
        export PROFILE=managed-cluster
    fi
 }


while IFS= read -r cluster_id
do
    oci ce cluster create-kubeconfig --cluster-id "$cluster_id" --file "$HOME"/.kube/cluster"$i"\_config --region us-ashburn-1 --token-version 2.0.0  --kube-endpoint PUBLIC_ENDPOINT
    kubectl --kubeconfig=$HOME/.kube/cluster"$i"\_config apply -f https://github.com/verrazzano/verrazzano/releases/download/v1.3.3/operator.yaml
    kubectl --kubeconfig=$HOME/.kube/cluster"$i"\_config -n verrazzano-install rollout status deployment/verrazzano-platform-operator
    config $i
    kubectl --kubeconfig=$HOME/.kube/cluster"$i"\_config apply -f - <<EOF
apiVersion: install.verrazzano.io/v1alpha1
kind: Verrazzano
metadata:
    name: ${META_NAME}
spec:
    profile: ${PROFILE}
    components:
        ingress:
            type: LoadBalancer
            nginxInstallArgs:
            - name:  controller.service.annotations."service\.beta\.kubernetes\.io/oci-load-balancer-shape"
              value: "10Mbps"
            - name: controller.service.annotations."service\.beta\.kubernetes\.io/oci-load-balancer-internal"
              value: "false"
EOF
    i=$((i+1))
    echo $i
done <<< "$clusters"

# Esperar a que termine la instalacion ...

export ADMIN_K8S_SERVER_ADDRESS="https:"$(kubectl --kubeconfig $HOME/.kube/cluster0\_config config view --minify | grep "server" | cut -d ":" -f 3,4)
i=0
while IFS= read -r cluster_id
do
    config $i
    echo "cluster $i"
    echo "Esperando status installComplete de instalacion: verrazzano/${META_NAME}"
    kubectl  --kubeconfig=$HOME/.kube/cluster"$i"\_config wait \
    --timeout=20m \
    --for=condition=InstallComplete verrazzano/${META_NAME}
    if [[ "$i" -gt 0 ]]; then
    export MGD_CA_CERT=$(kubectl --kubeconfig=$HOME/.kube/cluster"$i"\_config \
        get secret verrazzano-tls \
        -n verrazzano-system \
        -o jsonpath="{.data.ca\.crt}" | base64 --decode)
    kubectl --kubeconfig=$HOME/.kube/cluster"$i"\_config \
    create secret generic "ca-secret-managed$i" \
    -n verrazzano-mc \
    --from-literal=cacrt="$MGD_CA_CERT" \
    --dry-run=client \
    -o yaml > managed"$i".yaml
    kubectl --kubeconfig=$HOME/.kube/cluster0\_config \
     apply -f managed$i.yaml
    kubectl --kubeconfig=$HOME/.kube/cluster0\_config  \
        apply -f - <<EOF
apiVersion: clusters.verrazzano.io/v1alpha1
kind: VerrazzanoManagedCluster
metadata:
  name: managed$i
  namespace: verrazzano-mc
spec:
  description: "Test VerrazzanoManagedCluster object"
  caSecret: ca-secret-managed$i
EOF
    kubectl --kubeconfig=$HOME/.kube/cluster0\_config \
    wait --for=condition=Ready \
    vmc managed"$i" -n verrazzano-mc
    kubectl --kubeconfig=$HOME/.kube/cluster0\_config \
        get vmc managed$i -n verrazzano-mc -o yaml
    kubectl --kubeconfig=$HOME/.kube/cluster0\_config \
        get secret verrazzano-cluster-managed$i-manifest \
        -n verrazzano-mc \
        -o jsonpath={.data.yaml} | base64 --decode > register.yaml
    kubectl --kubeconfig $HOME/.kube/cluster$i\_config \
        apply -f register.yaml
    kubectl --kubeconfig=$HOME/.kube/cluster0\_config \
    wait --for=condition=Ready \
    vmc managed$i -n verrazzano-mc
else
    kubectl --kubeconfig=$HOME/.kube/cluster0\_config \
    apply -f <<EOF -
apiVersion: v1
kind: ConfigMap
metadata:
  name: verrazzano-admin-cluster
  namespace: verrazzano-mc
data:
  server: "${ADMIN_K8S_SERVER_ADDRESS}"
EOF
fi
    i=$((i+1))
    echo $i
done <<< "$clusters"

## Esperar a que acaben de subir los pods

kubectl --kubeconfig=$HOME/.kube/cluster0\_config \
    wait --for=condition=Ready \
    vmc managed1 -n verrazzano-mc
    
kubectl --kubeconfig=$HOME/.kube/cluster0\_config label namespace default verrazzano-managed=true istio-injection=enabled
kubectl --kubeconfig=$HOME/.kube/cluster0\_config create ns hello-helidon
kubectl --kubeconfig=$HOME/.kube/cluster0\_config label namespace hello-helidon verrazzano-managed=true istio-injection=enabled
kubectl --kubeconfig=$HOME/.kube/cluster0\_config apply -f https://raw.githubusercontent.com/verrazzano/verrazzano/v1.3.3/examples/hello-helidon/hello-helidon-comp.yaml -n hello-helidon
kubectl --kubeconfig=$HOME/.kube/cluster0\_config apply -n verrazzano-mc -f hello-hellidom-mc.yaml
kubectl --kubeconfig=$HOME/.kube/cluster0\_config apply \
     -n hello-helidon -f deploy-app-mc.yaml

kubectl --kubeconfig=$HOME/.kube/cluster0\_config \
    get vmc managed1 -n verrazzano-mc -o yaml


HOST=$(kubectl --kubeconfig $HOME/.kube/cluster1\_config get gateways.networking.istio.io hello-helidon-hello-helidon-appconf-gw \
     -n hello-helidon \
     -o jsonpath='{.spec.servers[0].hosts[0]}')


kubectl --kubeconfig=$HOME/.kube/cluster2_config wait \
   --for=condition=Ready pods \
   --all \
   -n hello-helidon \
   --timeout=300s

# CLEAN UP

kubectl --kubeconfig=$HOME/.kube/cluster0\_config label namespace default verrazzano-managed=true istio-injection=enabled
kubectl --kubeconfig=$HOME/.kube/cluster0\_config delete ns hello-helidon
kubectl --kubeconfig=$HOME/.kube/cluster0\_config delete -f https://raw.githubusercontent.com/verrazzano/verrazzano/v1.3.3/examples/hello-helidon/hello-helidon-comp.yaml -n hello-helidon
kubectl --kubeconfig=$HOME/.kube/cluster0\_config delete -n verrazzano-mc -f hello-hellidom-mc.yaml
kubectl --kubeconfig=$HOME/.kube/cluster0\_config delete \
     -n hello-helidon -f deploy-app-mc.yaml

# verrazano console: user: verrazzano

kubectl --kubeconfig=$HOME/.kube/cluster0_config get vz -o yaml
kubectl --kubeconfig=$HOME/.kube/cluster0_config get secret \
    --namespace verrazzano-system verrazzano \
    -o jsonpath={.data.password} | base64 \
    --decode; echo


# rancher, user: admin

kubectl --kubeconfig=$HOME/.kube/cluster0\_config get secret \
    --namespace cattle-system rancher-admin-secret \
    -o jsonpath={.data.password} | base64 \
    --decode; echo



kubectl --kubeconfig=$HOME/.kube/cluster0\_config get mcappconf hello-helidon-appconf \
    -n hello-helidon \
    -o jsonpath='{.spec.placement}';echo

# curl inside the cluster 

kubectl run curl-pod --image=radial/busyboxplus:curl -i --tty --rm