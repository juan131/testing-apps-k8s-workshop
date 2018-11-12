#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Load libraries
. $(git rev-parse --show-toplevel)/scripts/lib/liblog.bash

# Minikube Installation
info "Downloading Minikube binary..."
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-amd64
chmod +x minikube
sudo mv minikube /usr/local/bin/

# Kubectl Installation
info "Downloading kubectl binary..."
stable_kubectl_version="$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)"
curl -Lo kubectl "https://storage.googleapis.com/kubernetes-release/release/${stable_kubectl_version}/bin/darwin/amd64/kubectl"
chmod +x ./kubectl
sudo mv kubectl /usr/local/bin/

## Helm Installation
info "Downloading helm binary..."
curl -Lo helm-v2.11.0-darwin-amd64.tar.gz https://storage.googleapis.com/kubernetes-helm/helm-v2.11.0-darwin-amd64.tar.gz
tar xfv helm-v2.11.0-darwin-amd64.tar.gz
sudo mv darwin-amd64/helm /usr/local/bin

# Let's start Minikube!!
info "Starting Minikube..."
minikube start  # You increase the RAM memory allocated using: `minikube start --memory 4096`
minikube addons enable ingress
eval $(minikube docker-env) # Reuse the Docker daemon from Minikube

# Configure Kubectl to use Minikube
kubectl config set-context minikube

# Initialize Helm
info "Initializing Helm..."
helm init
# Add Bitnami Helm Chart repository
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

info "Creating namespaces..."
# Create a namespace for testing
kubectl create ns staging
# Create a namespace for testing
kubectl create ns production
