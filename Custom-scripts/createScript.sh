#!/usr/bin/env bash
set -euo pipefail

echo "Starting cluster setup..."
#CONFIGURE THESE PATHS BEFORE RUNNING
CLUSTER_MANIFEST="$HOME/Documents/Learn/Fampay-dev/bran/Global-K8s-Configs/K8s-configs/cluster-config.yaml"      
HODR_DIR="$HOME/Documents/Learn/Fampay-dev/hodr"
BRAN_DIR="$HOME/Documents/Learn/Fampay-dev/bran"
#K8S_DIR="$HOME/Documents/Learn/Fampay-dev/bran"
CLUSTER_NAME="fampay-dev"


# Create/ensure namespace & core cluster resources"
KIND_EXPERIMENTAL_PROVIDER=podman kind create cluster --name ${CLUSTER_NAME} --config "${CLUSTER_MANIFEST}"
#kind create cluster --name ${CLUSTER_NAME} --config "${CLUSTER_MANIFEST}"
kubectl config use-context "kind-${CLUSTER_NAME}"
kubectl create namespace fampay-dev
kubectl config set-context --current --namespace=fampay-dev
echo "Cluster created!"

# Build container images with Podman
#podman build -f "${HODR_DIR}/Dockerfile" -t localhost/hodr-app:latest "${HODR_DIR}"
docker build --no-cache -f "${HODR_DIR}/Dockerfile" -t hodr-app:latest "${HODR_DIR}"
docker build --no-cache -f "${BRAN_DIR}/Dockerfile" -t bran-app:latest   "${BRAN_DIR}"
echo "All Images build completed!"

#Save images to tarballs
#podman save localhost/hodr-app:latest -o hodr-app.tar
docker save hodr-app:latest -o hodr-app.tar
docker save bran-app:latest -o bran-app.tar
echo "Save images to tarballs"

#Load images into Kind cluster
kind load docker-image hodr-app:latest --name "${CLUSTER_NAME}"
kind load docker-image bran-app:latest --name "${CLUSTER_NAME}"
echo "All images loaded into Kind cluster nodes!"

#Install Metrics Server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl -n kube-system patch deployment metrics-server \
  --type='json' \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
kubectl -n kube-system rollout restart deployment/metrics-server
echo "Deployed Metrics Server!"

#Deploy Cluster Autoscaler (dry-run manifests)
kubectl create -f "$HOME/Documents/Learn/Fampay-dev/bran/Global-K8s-Configs/K8s-configs/ClusterAutoscaler/clusterautoscaler-sa.yaml"
kubectl create -f "$HOME/Documents/Learn/Fampay-dev/bran/Global-K8s-Configs/K8s-configs/ClusterAutoscaler/clusterautoscaler-role.yaml"
kubectl create -f "$HOME/Documents/Learn/Fampay-dev/bran/Global-K8s-Configs/K8s-configs/ClusterAutoscaler/clusterautoscaler-rolebinding.yaml"
kubectl create -f "$HOME/Documents/Learn/Fampay-dev/bran/Global-K8s-Configs/K8s-configs/ClusterAutoscaler/clusterautoscaler-deploy.yaml"
echo "Deployed ClusterAutoscaler!"

#Install calico for ingress and egress netpol rules
echo "Waiting for calico to come up ..."
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
kubectl -n kube-system \
  wait --for=condition=Ready pod \
  -l k8s-app=calico-node --timeout=300s
kubectl -n kube-system delete daemonset kindnet

#Deploy NGINX proxy
kubectl create -f "$HOME/Documents/Learn/Fampay-dev/bran/Global-K8s-Configs/K8s-configs/nginx-cm.yaml"
kubectl create -f "$HOME/Documents/Learn/Fampay-dev/bran/Global-K8s-Configs/K8s-configs/nginx-deploy.yaml"
kubectl create -f "$HOME/Documents/Learn/Fampay-dev/bran/Global-K8s-Configs/K8s-configs/nginx-svc.yaml"
echo "Deployed Nginx Proxy!"

#Deploy Squid proxy
#kubectl create -f "Global-K8s-Configs/K8s-configs/squid-cm.yaml"
#kubectl create -f "Global-K8s-Configs/K8s-configs/squid-deploy.yaml"
#kubectl create -f "Global-K8s-Configs/K8s-configs/squid-svc.yaml"
#echo "Deployed Squid Proxy!"

#Apply network policies
kubectl create -f "$HOME/Documents/Learn/Fampay-dev/bran/Global-K8s-Configs/K8s-configs/network-policy-ingress.yaml"
#kubectl create -f "Global-K8s-Configs/K8s-configs/network-policy-egress.yaml"
echo "Applied Network Policies!"

#Deploy app secrets/config & workloads"
kubectl apply -f "$HOME/Documents/Learn/Fampay-dev/bran/k8sConfig-bran/bran-secret.yaml"
kubectl apply -f "$HOME/Documents/Learn/Fampay-dev/bran/k8sConfig-bran/bran-cm.yaml"
kubectl apply -f "$HOME/Documents/Learn/Fampay-dev/bran/k8sConfig-bran/bran-deploy.yaml"
kubectl apply -f "$HOME/Documents/Learn/Fampay-dev/bran/k8sConfig-bran/bran-svc.yaml"
kubectl apply -f "$HOME/Documents/Learn/Fampay-dev/bran/k8sConfig-bran/bran-hpa.yaml"
kubectl apply -f "/Users/shivam.marathe/Documents/Learn/Fampay-dev/hodr/K8s-configs-hodr/hodr-deploy.yaml"
kubectl apply -f "/Users/shivam.marathe/Documents/Learn/Fampay-dev/hodr/K8s-configs-hodr/hodr-svc.yaml"
kubectl apply -f "/Users/shivam.marathe/Documents/Learn/Fampay-dev/hodr/K8s-configs-hodr/hodr-hpa.yaml"
echo "Application is Deployed!"


echo "K8s cluster \"${CLUSTER_NAME}\" should now be up with metrics, autoscaling, proxies, and both services deployed."
