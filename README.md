# Setup multicluster
- [Setup multicluster](#setup-multicluster)
  - [Install Verazzano Operator](#install-verazzano-operator)
  - [Install Verazzano:](#install-verazzano)
  - [Prometeus and Grafana Operators](#prometeus-and-grafana-operators)
  - [Install Sample Helm App](#install-sample-helm-app)


[Ref](https://verrazzano.io/latest/docs/setup/install/multicluster/)


**NOTE** Create cluster On v1.23.4

## Install Verazzano Operator

Install operator in master and slave

```shell
kubectl apply -f https://github.com/verrazzano/verrazzano/releases/download/v1.3.3/operator.yaml



customresourcedefinition.apiextensions.k8s.io/verrazzanomanagedclusters.clusters.verrazzano.io created
customresourcedefinition.apiextensions.k8s.io/verrazzanos.install.verrazzano.io created
namespace/verrazzano-install created
serviceaccount/verrazzano-platform-operator created
clusterrole.rbac.authorization.k8s.io/verrazzano-managed-cluster created
clusterrolebinding.rbac.authorization.k8s.io/verrazzano-platform-operator created
service/verrazzano-platform-operator created
deployment.apps/verrazzano-platform-operator created
validatingwebhookconfiguration.admissionregistration.k8s.io/verrazzano-platform-operator created

```

## Install Verazzano: 

`kubectl apply -f admin_verazzanno.yaml`

`kubectl apply -f slave_verazzanno.yaml`

---

To check log files for verazzanno installation: 

```shell
kubectl logs -n verrazzano-install \
    -f $(kubectl get pod \
    -n verrazzano-install \
    -l app=verrazzano-platform-operator \
    -o jsonpath="{.items[0].metadata.name}") | grep '^{.*}$' \
    | jq -r '."@timestamp" as $timestamp | "\($timestamp) \(.level) \(.message)"'

```

---


Follow this [documentation](https://verrazzano.io/latest/docs/setup/install/multicluster/) for multicluster config


```shell
export KUBECONFIG_ADMIN=/home/ubuntu/.kube/master/config
export KUBECONFIG_MANAGED1=/home/ubuntu/.kube/slave/config


kubectl --kubeconfig $KUBECONFIG_ADMIN config get-contexts -o=name
context-c6w5anqpocq

kubectl --kubeconfig $KUBECONFIG_MANAGED1 config get-contexts -o=name
context-ciq7fd5y73q

# Choose the right context name for your admin and managed clusters from the output shown and set the KUBECONTEXT
# environment variables
export KUBECONTEXT_ADMIN=context-c6w5anqpocq
export KUBECONTEXT_MANAGED1=context-ciq7fd5y73q
```


---

## Prometeus and Grafana Operators

$ kubectl create namespace monitoring
$ helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
$ helm repo update 
$ helm upgrade --namespace monitoring --install kube-stack-prometheus prometheus-community/kube-prometheus-stack --set prometheus-node-exporter.hostRootFsMount.enabled=false


---
## Install Sample Helm App

[Ref](https://verrazzano.io/latest/docs/samples/multicluster/hello-helidon/)


The source code in application is available [here](https://github.com/verrazzano/examples/tree/master/hello-helidon)

