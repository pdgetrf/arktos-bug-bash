#!/bin/bash

set -x

if [ "$#" -lt 1 ]
then
        echo "Usage: setup-tenant.sh [tenant] [ip]"
        exit 1
fi

### create tenant
./hack/setup-multi-tenancy/create_tenant.sh $1

### create users
users=( admin john )
certfiles=""
for user in "${users[@]}"
do
        ./hack/setup-multi-tenancy/setup_client.sh $1 $user ${2:-localhost}
        cred_name=$1-$user
        certfiles="$certfiles $cred_name.crt $cred_name.key"
done
certfiles="$certfiles -C /var/run/kubernete  server-ca.crt"

configname=$1.kubeconfig
sed "s/replacewithtenant/$1/g" template.kubeconfig > $configname

tarname=$1.tar
tar cjf $tarname $configname $certfiles
echo certfiles zipped to $tarname
