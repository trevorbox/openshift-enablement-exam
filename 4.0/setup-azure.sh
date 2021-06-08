
set -o nounset
set -o errexit

function create_openshift()
{
  mkdir -p ./cluster-azure$CLUSTER_ID
  export pull_secret=$(cat ./pullsecret.json)
  envsubst < ./config-azure/install-config-raffa1.yaml > ./cluster-azure$CLUSTER_ID/install-config.yaml
  openshift-install create cluster --dir ./cluster-azure$CLUSTER_ID --log-level debug
  export KUBECONFIG=/home/rspazzol/git/openshift-enablement-exam/4.0/cluster-azure$CLUSTER_ID/auth/kubeconfig
  # create route 
  oc create route reencrypt apiserver --service kubernetes --port https -n default
  # add simple user
  htpasswd -c -B -b ./cluster-azure$CLUSTER_ID/auth/htpasswd raffa raffa
  oc create secret generic htpass-secret --from-file=htpasswd=./cluster-azure$CLUSTER_ID/auth/htpasswd -n openshift-config
  oc apply -f ../misc4.0/htpasswd/oauth.yaml -n openshift-config
  oc adm policy add-cluster-role-to-user cluster-admin raffa
}

#download_installer
#configure_aws_credentials
CLUSTER_ID=1 create_openshift 
#CLUSTER_ID=2 create_openshift 