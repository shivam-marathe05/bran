# FamPay SRE – Quick‑Start Guide

# Prerequisites
 
# 1. Install podman/docker
# 2. Install kind 
# 3. Install wget 
# 4. Install helm
# 5. Install curl/telnet/ping

Steps to install podman 4.9 -
wget https://github.com/containers/podman/releases/download/v4.9.3/podman-installer-macos-arm64.pkg
Then open directory with finder and install it
wget https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/39.20240407.3.0/aarch64/fedora-coreos-39.20240407.3.0-qemu.aarch64.qcow2.xz
podman machine init --image-path fedora-coreos-39.20240407.3.0-qemu.aarch64.qcow2.xz
podman machine start

brew install kind
brew install wget
brew install helm
brew install curl , telnet, ping  #for connectivity check

# For creating things from scratch please run create script 

# before running script please give access to that file 

chmod +x createScript.sh
./createScript.sh

# How to test ?

kubectl -n fampay-dev port-forward svc/nginx-proxy 30080:80 
#Run these commands externally
curl -s http://localhost:30080/hodr/        # 200
curl -s http://localhost:30080/bran/   # 200
curl -s http://localhost:30080/hodr/metrics        # 200
curl -s http://localhost:30080/bran/metrics      # 200

# Please run these commands internally
# Bran ➜ Hodor (should succeed)

kubectl exec deploy/bran  -- bash 
curl -vk http://hodr.fampay-dev.svc.cluster.local:8080  # 200

# Hodor ➜ Bran (should timeout)

kubectl exec deploy/hodr -- sh
curl -vk http://bran.fampay-dev.svc.cluster.local:8000  # timeout

# To setup monitoring stack, please run below script

chmod +x monitoringScript.sh
./monitoringScript.sh

# Done.
# In order to update your application , please run below script

chmod +x updateScript.sh
./updateScript.sh