#!/bin/bash

# Exit on any error
set -e

# Step 1: Create monitoring namespace
echo "Creating 'monitoring' namespace..."
kubectl create namespace monitoring || echo "Namespace already exists."

# Step 2: Set current context to monitoring
echo "Setting current context to use 'monitoring' namespace..."
kubectl config set-context --current --namespace=monitoring

# Step 3: Clone kube-prometheus repo if not already present
if [ ! -d "kube-prometheus" ]; then
    echo "Cloning kube-prometheus repository..."
    git clone https://github.com/prometheus-operator/kube-prometheus.git
else
    echo "kube-prometheus repo already cloned."
fi

# Step 4: Apply manifests
cd kube-prometheus

echo "Applying setup manifests..."
kubectl create -f manifests/setup/

echo "Waiting for CRDs to be established..."
sleep 20  # Wait for CRDs to be registered before applying the rest

echo "Applying monitoring stack manifests..."
kubectl create -f manifests/

#SVC Monitors
echo "Applying service monitor manifests..."
kubectl apply -f "/Users/shivam.marathe/Documents/Learn/Fampay-dev/bran/Global-K8s-Configs/Monitoring-configs/bran-svc-monitor.yaml"
kubectl apply -f "/Users/shivam.marathe/Documents/Learn/Fampay-dev/bran/Global-K8s-Configs/Monitoring-configs/hodr-svc-monitor.yaml"

echo "Monitoring stack deployed successfully!"
