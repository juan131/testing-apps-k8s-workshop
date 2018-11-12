#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# Load libraries
. $(git rev-parse --show-toplevel)/scripts/lib/liblog.bash

# Set Testing Mode
TESTING_MODE=${1:-"staging"}

if [[ "$TESTING_MODE" = "production" ]] || [[ "$TESTING_MODE" = "staging" ]]; then
  info "Testing on $TESTING_MODE..."

  # Configure your kubectl context to use the proper namespace
  kubectl config set-context "$(kubectl config current-context)" --namespace="$TESTING_MODE"

  job_name="testing-job"
  job_file="$(git rev-parse --show-toplevel)/testing-job/definitions/job-${TESTING_MODE}.yaml"

  # Deploy K8s job
  info "Deploying testing job..."
  kubectl create -f "$job_file"

  finished=0
  failed=0
  info "Waiting for testing job to succeed..."
  while [[ $finished -eq 0 ]]; do
    job_status="$(kubectl get jobs/${job_name} -o jsonpath='{.status}')"
    job_log="$(kubectl logs jobs/${job_name} 2>&1 || true)"
    info "Job status:\n${job_status}\n------"

    # Check logs
    if grep -q 'is waiting to start: ' <<< "${job_log}"; then
      pod="$(kubectl get pods -l "job-name = ${job_name}" -o name)"
      provision_log="$(kubectl logs ${pod} 2>&1 || true)"
      pod_desription="$(kubectl describe ${pod} 2>&1)"
      info "Provision pod log:\n${provision_log}\n------\n"
      info "Provision pod description:\n${pod_desription}\n------\n"
    fi

    # Check job' status
    if [[ "$(kubectl get jobs/${job_name} -o jsonpath='{.status.succeeded}')" -eq 1 ]]; then
      finished=1
    elif [[ "$(kubectl get jobs/${job_name} -o jsonpath='{.status.failed}')" -eq 1 ]]; then
      error "The job failed too many times. Exiting now!"
      finished=1
      failed=1
    fi
    [[ $finished -eq 0 ]] && sleep 5
  done


  job_log="$(kubectl logs jobs/${job_name} 2>&1 || true)"
  info "Job full log:\n${job_log}\n------\n"
  # Scan tests looking for failures
  if grep -q 'failing' <<< "${job_log}"; then
    failed=1
    error "Tests failed!!!"
  fi

else
    error "Testing mode \"$TESTING_MODE\" not supported"
    error " - Supported testing modes are: production and staging"
fi

info "Deleting K8s job..."
kubectl delete jobs/${job_name}
