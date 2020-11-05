
set -o nounset
set -o errexit

function create_openshift()
{
  mkdir -p $HOME/cluster$CLUSTER_ID
  cp ./config/install-config-tbox$CLUSTER_ID.yaml $HOME/cluster$CLUSTER_ID/install-config.yaml
  #~/Downloads/openshift-install-linux-4.4.0-0.nightly-2020-02-17-103442/openshift-install create cluster --dir $HOME/cluster$CLUSTER_ID --log-level debug
  openshift-install create cluster --dir $HOME/cluster$CLUSTER_ID --log-level debug
  export KUBECONFIG=$HOME/cluster$CLUSTER_ID/auth/kubeconfig
  # create route 
  oc create route reencrypt apiserver --service kubernetes --port https -n default
  # add simple user
  htpasswd -c -B -b $HOME/cluster$CLUSTER_ID/auth/htpasswd raffa raffa
  htpasswd -B -b $HOME/cluster$CLUSTER_ID/auth/htpasswd tbox 'r3dh4t1!'
  htpasswd -B -b $HOME/cluster$CLUSTER_ID/auth/htpasswd dev  'r3dh4t1!'
  oc create secret generic htpass-secret --from-file=htpasswd=$HOME/cluster$CLUSTER_ID/auth/htpasswd -n openshift-config
  oc apply -f ../misc4.0/htpasswd/oauth.yaml -n openshift-config
  oc adm policy add-cluster-role-to-user cluster-admin raffa
  oc adm policy add-cluster-role-to-user cluster-admin tbox
}

#download_installer
#configure_aws_credentials
CLUSTER_ID=1 create_openshift 
#CLUSTER_ID=2 create_openshift 