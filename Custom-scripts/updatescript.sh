#!/usr/bin/env bash
set -euo pipefail

#CONFIGURE THESE PATHS BEFORE RUNNING
 
HODR_DIR="$HOME/Documents/Learn/Fampay-dev/hodr"
BRAN_DIR="$HOME/Documents/Learn/Fampay-dev/bran"
CLUSTER_NAME="fampay-dev"

echo "Image building ..."
# Build container images with Podman
docker build -f "${HODR_DIR}/Dockerfile" -t hodr-app:latest "${HODR_DIR}"
docker build -f "${BRAN_DIR}/Dockerfile" -t bran-app:latest   "${BRAN_DIR}"
echo "Image built!"

#Save images to tarballs
echo "Saving in tarball ..."
docker save hodr-app:latest -o hodr-app.tar
docker save bran-app:latest -o bran-app.tar
echo "Images saved in .tar"

#Load images into Kind cluster
echo "Loading Images to nodes ..."
kind load docker-image hodr-app:latest --name "${CLUSTER_NAME}"
kind load docker-image bran-app:latest --name "${CLUSTER_NAME}"
echo "Image loaded on nodes!"

#Taking backups before applying new images
echo "Taking backups before applying new images ..."
kubectl get deployment bran -oyaml -n "${CLUSTER_NAME}" > bran-bkp.yaml
kubectl get deployment hodr -oyaml -n "${CLUSTER_NAME}" > hodr-bkp.yaml
echo "Backup completed!"

#Deploy app secrets/config & workloads"
echo "Applying latest Images ..."
kubectl rollout restart deployment bran -n "${CLUSTER_NAME}"
kubectl rollout restart deployment hodr -n "${CLUSTER_NAME}"
echo "Applied latest Images, Please monitor!"
echo "Updated latest images in App"