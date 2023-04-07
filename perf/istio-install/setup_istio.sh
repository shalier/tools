#!/bin/bash

# Copyright Istio Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -ex

WD=$(dirname "$0")
WD=$(cd "$WD"; pwd)
DIRNAME="${WD}/tmp"
mkdir -p "${DIRNAME}"
export GO111MODULE=on

case "${OSTYPE}" in
  darwin*) export ARCH_SUFFIX="${ARCH_SUFFIX:-osx}" ;;
  linux*) export ARCH_SUFFIX="${ARCH_SUFFIX:-linux-amd64}" ;;
  *) echo "unsupported: ${OSTYPE}" ;;
esac

IOPS="${IOPS:-istioctl_profiles/long-running.yaml,istioctl_profiles/long-running-gateway.yaml}"
OUT_FILE="istio-${DEV_VERSION}"
RELEASE_URL="https://storage.googleapis.com/istio-build/dev/${DEV_VERSION}/istio-${DEV_VERSION}-${ARCH_SUFFIX}.tar.gz"

function download_release() {
  outfile="${DIRNAME}/${OUT_FILE}"
  if [[ ! -d "${outfile}" ]]; then
    tmp=$(mktemp -d)
    curl -fJLs -o "${tmp}/out.tar.gz" "${RELEASE_URL}"
    tar xvf "${tmp}/out.tar.gz" -C "${DIRNAME}"
  else
    echo "${outfile} already exists, skipping download"
  fi
}

function install_istioctl() {
  release=${1:?release folder}
  shift
  for i in ${IOPS//,/ }; do
    "${release}/bin/istioctl" install --skip-confirmation -d "${release}/manifests" -f "${i}" "${@}"
  done
}

function install_extras() {
  local domain=${DNS_DOMAIN:?"DNS_DOMAIN like v104.qualistio.org"}
  local certmanagerEmail=${CERTMANAGER_EMAIL:-""}
  kubectl create namespace istio-system || true
  # Deploy the gateways and prometheus operator.
  # Deploy CRDs with create, they are too big otherwise
  kubectl create -f base/files || true # Might fail if we already installed, so allow failures
  if [[ "${certmanagerEmail:-}" != "" ]]; then
    kubectl apply -f "${WD}/addons/cert-manager.yaml"
    kubectl wait --for=condition=Available deployments --all -n cert-manager
    helm template --set domain="${domain}" --set certManager.email="${certmanagerEmail}" --set certManager.enabled=true "${WD}/base" | kubectl apply -f -
  else
    helm template --set domain="${domain}" "${WD}/base" | kubectl apply -f -
  fi

  # Check deployment
  MAXRETRIES=0
  until kubectl rollout status --watch --timeout=60s deployment/prometheus -n istio-system || [ $MAXRETRIES -eq 60 ]
  do
    MAXRETRIES=$((MAXRETRIES + 1))
    sleep 5
  done
  if [[ $MAXRETRIES -eq 60 ]]; then
    echo "prometheus were not created successfully"
    exit 1
  fi

  # deploy grafana
  kubectl apply -f "${release}/samples/addons/grafana.yaml" -n istio-system
  kubectl apply -f "${WD}/addons/grafana-cm.yaml" -n istio-system # override just the configmap
  kubectl rollout restart deployment grafana -n istio-system # restart to ensure it picks up our new configmap
}

if [[ -z "${SKIP_INSTALL}" ]];then
  if [[ -z "${LOCAL_ISTIO_PATH}" ]];then
    download_release
    install_istioctl "${DIRNAME}/${OUT_FILE}" "${@}"

    if [[ -z "${SKIP_EXTRAS:-}" ]]; then
      install_extras
    fi
    # if LOCAL_ISTIO_PATH is set, we assume that Istio is preconfigured, we only install extra monitoring/alerting configs.
  else
    release="${LOCAL_ISTIO_PATH}"
    install_extras
  fi
fi
