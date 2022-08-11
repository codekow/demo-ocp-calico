#!/bin/bash
# see https://projectcalico.docs.tigera.io/getting-started/windows-calico/openshift/installation
# set -x

INSTALL_DIR=ocp-calico-install
TMP_DIR=generated

setup_bin() {
  mkdir -p ${TMP_DIR}/bin
  echo ${PATH} | grep -q "${TMP_DIR}/bin" || \
    export PATH=${TMP_DIR}/bin:$PATH
}

check_ocp_install() {
  which openshift-install 2>&1 >/dev/null || download_ocp_install
  echo "auto-complete: . <(openshift-install completion bash)"
  . <(openshift-install completion bash)
  openshift-install version
  sleep 5
}

check_oc() {
  which oc 2>&1 >/dev/null || download_oc
  echo "auto-complete: . <(oc completion bash)"
  . <(oc completion bash)
  oc version
  sleep 5
}

download_ocp_install() {
  DOWNLOAD_URL=https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable-4.10/openshift-install-linux.tar.gz
  curl "${DOWNLOAD_URL}" -L | tar vzx -C ${TMP_DIR}/bin openshift-install
}

download_oc() {
  DOWNLOAD_URL=https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable-4.10/openshift-client-linux.tar.gz
  curl "${DOWNLOAD_URL}" -L | tar vzx -C ${TMP_DIR}/bin oc
}


calico_init_install() {
    cd ${TMP_DIR}
    [ ! -d ${INSTALL_DIR} ] && mkdir ${INSTALL_DIR}
    cd ${INSTALL_DIR}
    
    [ -e install-config.yaml ] || openshift-install create install-config

    [ -e install-config.yaml ] || exit
}

calico_update_sdn() {
  sed -i 's/OpenShiftSDN/Calico/' install-config.yaml
  cp install-config.yaml ../install-config.yaml-$(date +%s)
}

calico_download_manifests() {
  openshift-install create manifests

  [ ! -d manifests ] && mkdir manifests
  curl https://projectcalico.docs.tigera.io/manifests/ocp/crds/01-crd-apiserver.yaml -o manifests/01-crd-apiserver.yaml
  curl https://projectcalico.docs.tigera.io/manifests/ocp/crds/01-crd-installation.yaml -o manifests/01-crd-installation.yaml
  curl https://projectcalico.docs.tigera.io/manifests/ocp/crds/01-crd-imageset.yaml -o manifests/01-crd-imageset.yaml
  curl https://projectcalico.docs.tigera.io/manifests/ocp/crds/01-crd-tigerastatus.yaml -o manifests/01-crd-tigerastatus.yaml
  curl https://projectcalico.docs.tigera.io/manifests/ocp/crds/calico/crd.projectcalico.org_bgpconfigurations.yaml -o manifests/crd.projectcalico.org_bgpconfigurations.yaml
  curl https://projectcalico.docs.tigera.io/manifests/ocp/crds/calico/crd.projectcalico.org_bgppeers.yaml -o manifests/crd.projectcalico.org_bgppeers.yaml
  curl https://projectcalico.docs.tigera.io/manifests/ocp/crds/calico/crd.projectcalico.org_blockaffinities.yaml -o manifests/crd.projectcalico.org_blockaffinities.yaml
  curl https://projectcalico.docs.tigera.io/manifests/ocp/crds/calico/crd.projectcalico.org_caliconodestatuses.yaml -o manifests/crd.projectcalico.org_caliconodestatuses.yaml
  curl https://projectcalico.docs.tigera.io/manifests/ocp/crds/calico/crd.projectcalico.org_clusterinformations.yaml -o manifests/crd.projectcalico.org_clusterinformations.yaml
  curl https://projectcalico.docs.tigera.io/manifests/ocp/crds/calico/crd.projectcalico.org_felixconfigurations.yaml -o manifests/crd.projectcalico.org_felixconfigurations.yaml
  curl https://projectcalico.docs.tigera.io/manifests/ocp/crds/calico/crd.projectcalico.org_globalnetworkpolicies.yaml -o manifests/crd.projectcalico.org_globalnetworkpolicies.yaml
  curl https://projectcalico.docs.tigera.io/manifests/ocp/crds/calico/crd.projectcalico.org_globalnetworksets.yaml -o manifests/crd.projectcalico.org_globalnetworksets.yaml
  curl https://projectcalico.docs.tigera.io/manifests/ocp/crds/calico/crd.projectcalico.org_hostendpoints.yaml -o manifests/crd.projectcalico.org_hostendpoints.yaml
  curl https://projectcalico.docs.tigera.io/manifests/ocp/crds/calico/crd.projectcalico.org_ipamblocks.yaml -o manifests/crd.projectcalico.org_ipamblocks.yaml
  curl https://projectcalico.docs.tigera.io/manifests/ocp/crds/calico/crd.projectcalico.org_ipamconfigs.yaml -o manifests/crd.projectcalico.org_ipamconfigs.yaml
  curl https://projectcalico.docs.tigera.io/manifests/ocp/crds/calico/crd.projectcalico.org_ipamhandles.yaml -o manifests/crd.projectcalico.org_ipamhandles.yaml
  curl https://projectcalico.docs.tigera.io/manifests/ocp/crds/calico/crd.projectcalico.org_ippools.yaml -o manifests/crd.projectcalico.org_ippools.yaml
  curl https://projectcalico.docs.tigera.io/manifests/ocp/crds/calico/crd.projectcalico.org_ipreservations.yaml -o manifests/crd.projectcalico.org_ipreservations.yaml
  curl https://projectcalico.docs.tigera.io/manifests/ocp/crds/calico/crd.projectcalico.org_kubecontrollersconfigurations.yaml -o manifests/crd.projectcalico.org_kubecontrollersconfigurations.yaml
  curl https://projectcalico.docs.tigera.io/manifests/ocp/crds/calico/crd.projectcalico.org_networkpolicies.yaml -o manifests/crd.projectcalico.org_networkpolicies.yaml
  curl https://projectcalico.docs.tigera.io/manifests/ocp/crds/calico/crd.projectcalico.org_networksets.yaml -o manifests/crd.projectcalico.org_networksets.yaml
  curl https://projectcalico.docs.tigera.io/manifests/ocp/tigera-operator/00-namespace-tigera-operator.yaml -o manifests/00-namespace-tigera-operator.yaml
  curl https://projectcalico.docs.tigera.io/manifests/ocp/tigera-operator/02-rolebinding-tigera-operator.yaml -o manifests/02-rolebinding-tigera-operator.yaml
  curl https://projectcalico.docs.tigera.io/manifests/ocp/tigera-operator/02-role-tigera-operator.yaml -o manifests/02-role-tigera-operator.yaml
  curl https://projectcalico.docs.tigera.io/manifests/ocp/tigera-operator/02-serviceaccount-tigera-operator.yaml -o manifests/02-serviceaccount-tigera-operator.yaml
  curl https://projectcalico.docs.tigera.io/manifests/ocp/tigera-operator/02-configmap-calico-resources.yaml -o manifests/02-configmap-calico-resources.yaml
  curl https://projectcalico.docs.tigera.io/manifests/ocp/tigera-operator/02-tigera-operator.yaml -o manifests/02-tigera-operator.yaml
  curl https://projectcalico.docs.tigera.io/manifests/ocp/01-cr-installation.yaml -o manifests/01-cr-installation.yaml
  curl https://projectcalico.docs.tigera.io/manifests/ocp/01-cr-apiserver.yaml -o manifests/01-cr-apiserver.yaml
}

calico_create_cr_vxlan() {

echo "
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
spec:
  variant: Calico
  calicoNetwork:
    bgp: Disabled
    ipPools:
    - blockSize: 26
      cidr: 10.128.0.0/14
      encapsulation: VXLAN
      natOutgoing: Enabled
      nodeSelector: all()
" > manifests/01-cr-installation.yaml

}

calico_backup_install() {
  cd ..
  [ ! -d install-$(date +%s) ] && cp -a ${INSTALL_DIR} install-$(date +%s)
}

calico_print_install() {
  echo "${TMP_DIR}/bin/openshift-install create cluster --dir ${TMP_DIR}/${INSTALL_DIR}"
  echo "export KUBECONFIG=${TMP_DIR}/${INSTALL_DIR}/auth/kubeconfig"
  export KUBECONFIG=${TMP_DIR}/${INSTALL_DIR}/auth/kubeconfig
}

setup_bin
check_ocp_install
check_oc
calico_init_install
calico_update_sdn
calico_download_manifests
calico_create_cr_vxlan
calico_backup_install
calico_print_install