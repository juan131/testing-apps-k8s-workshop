#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Load libraries
. $(git rev-parse --show-toplevel)/scripts/lib/liblog.bash

# Functions

########################
# Check if a deployemnt is ready
# Arguments:
#   $1 - Deployment Name
# Returns:
#   Boolean
#########################
is_deploy_ready() {
  local deploy_name="${1:?missing value}"

  if [[ "$(kubectl get deploy "$deploy_name" -o jsonpath='{.status.readyReplicas}')" != "1" ]]; then
    return 0
  else
    return 1
  fi
}
########################
# Check if a Chart has been already released
# Arguments:
#   $1 - Chart Name
# Returns:
#   Boolean
#########################
is_chart_released() {
  local chart_name="${1:?missing value}"
  local found=1

  read -r -a charts <<< "$(tr '\n' ' ' <<< "$(helm list --short)")"
  if [[ -n ${charts:-} ]]; then
    for chart in "${charts[@]}"; do
      if [[ "$chart" = "$chart_name" ]]; then
        found=0
      fi
    done
  fi
  return $found
}

# Set Testing Mode
TARGET=${1:-"staging"}

release_name="cms-staging"
cms_host="cms.testing.innosoft"
values_file="values-staging.yaml"

if [[ "$TARGET" = "production" ]] || [[ "$TARGET" = "staging" ]]; then
  info "Deploying to $TARGET..."

  # Configure your kubectl context to use the proper namespace
  kubectl config set-context "$(kubectl config current-context)" --namespace="$TARGET"

  if [[ "$TARGET" = "production" ]]; then
    release_name="cms-production"
    values_file="values-production.yaml"
    cms_host="cms.production.innosoft"
  fi

  if ! is_chart_released "$release_name"; then
    # Install Node Helm Chart
    #   - Ref: https://github.com/bitnami/charts/tree/master/bitnami/node
    info "Installing bitnami/node chart with CMS application..."
    helm install bitnami/node --name "$release_name" -f "$(git rev-parse --show-toplevel)/resources/${values_file}"
    echo "$(minikube ip)   $cms_host" | sudo tee -a /etc/hosts
  else
    # Upgrade chart
    warn "Chart already installed!!"
	  info "Upgrading chart with latest changes..."
    helm upgrade "$release_name" bitnami/node -f "$(git rev-parse --show-toplevel)/resources/${values_file}"
  fi

  info "Waiting for deployment to be ready..."
  counter=10
  while [[ "$counter" -ne 0 ]] && is_deploy_ready "${release_name}-node"; do
    sleep 5
    counter=$((counter - 1))
  done
  sleep 10
  info "Deployment ready!"

  # Set a password for Admin user
  echo "12345" | kubectl exec -i "$(kubectl get pods -l app=node,release=${release_name} -o jsonpath='{.items[0].metadata.name}')" -- node app.js apostrophe-users:add admin admin

else
  error "Target \"$TESTING_MODE\" not supported"
  error " - Supported Targets are: production and staging"
fi
