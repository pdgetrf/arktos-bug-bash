#!/bin/bash

if [ "$#" -lt 1 ]
then
        echo "Usage: setup-tenant.sh [tenant] [ip]"
        exit 1
fi

### create tenant
./create_tenant.sh $1

### create users
users=( admin john )
certfiles=""
host=${2:-localhost}
for user in "${users[@]}"
do
        ./setup_client.sh $1 $user $host 
        cred_name=$1-$user
        certfiles="$certfiles $cred_name.crt $cred_name.key"
done
certfiles="$certfiles -C /var/run/kubernetes server-ca.crt"

configname=$1.kubeconfig
sed "s/replacewithtenant/$1/g; s/localhost/$host/g" template.kubeconfig > $configname

tarname=$1.tar
tar cjf $tarname $configname $certfiles
echo
echo tenant $1 has been set up. find certs and kubeconfig in $tarname
