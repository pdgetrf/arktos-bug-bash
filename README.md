# Set Up Access to The Bug Bash Cluster

## Already Requested Tenants?
Find provisioned tenant for your name:

- [Qian Chen's tenant](https://efutureway.sharepoint.com/:u:/s/SeattleCloudLab/EZISaMvoC59Np2_Ln_ncE9QBt9IoeMTin93d6-MSo07FPA?e=D7TfoI)
- [Hongwei's tenant]()
- [Yunwen's tenant](https://efutureway.sharepoint.com/:u:/s/SeattleCloudLab/EfgVbiZRlXROmOcU-KuwvE8BMYdnVElsQmooCTQjEmhtRw?e=ep3Jyg)

## Where's the host?
The host endpoint is set in the [tenant name].kubeconfig file. It runs in AWS.

## Prepare kubectl
Compile kubectl from arktos master repo on your own machine, and make sure PATH is set correctly to pick it up.

## Get Certs

Call Peng for them. OKay, email works too. 

You will get a tar file that contains the certs for two users, admin and john. Also it contains the kubeconfig file and server-ca.crt. Untar all of these files to /tmp. Here's an example for a tenant "toyota"

```bash
root@ip-172-31-27-32:/tmp# tar xvf toyota.tar
toyota.kubeconfig
toyota-admin.crt
toyota-admin.key
toyota-john.crt
toyota-john.key
server-ca.crt
```

As you can see, there are two users provisioned for this tenant: "admin" and "john". "admin" is the tenant admin, and cluster role and binding are already created for him with full tenant access. No access exists yet for the user "john". This will be granted by user "admin" as he will. The [role_and_binding](./role_and_binding) folder has a set of sample role and binding for your convenience. Add your tenant name in them replacing the "[change me]" part.

## Setup KUBECONFIG

```bash
export KUBECONFIG=/tmp/[tenant name].kubeconfig
```


## Add Context Aliases
Run add-alias.sh to add the following alias for context switch:

```bash
tn=[your tenant name]
alias be-tenant-admin='kubectl config use-context $tn-admin-context'
alias be-john='kubectl config use-context $tn-john-context'
```

## Have Fun Breaking Arktos

As an example:

All the yamls here are from this very repo.

1. Become the tenant admin (if you have the cert)
```bash
root@ip-172-31-27-32:~/bug-bash/arktos-bug-bash# be-tenant-admin
Switched to context "toyota-admin-context".
```

2. Create roles and bindings for user:
```bash
root@ip-172-31-27-32:/tmp# kubectl create -f role-reader.yaml
role.rbac.authorization.k8s.io/reader created
root@ip-172-31-27-32:/tmp#
root@ip-172-31-27-32:/tmp# kubectl create -f rolebinding-reader.yaml
rolebinding.rbac.authorization.k8s.io/rolebinding-reader created
```

Again, these yamls are provided to you in the [role_and_binding](./role_and_binding) folder.

3. Create a deployment as the admin (or a job or whatever resource you want to test):
```bash
root@ip-172-31-27-32:~/bug-bash/arktos-bug-bash# kubectl create -f yamls/test_deployment.yaml
deployment.apps/futurewei-deployment created
root@ip-172-31-27-32:~/bug-bash/arktos-bug-bash#
root@ip-172-31-27-32:~/bug-bash/arktos-bug-bash# kubectl get pods,deployment
NAME                                        HASHKEY               READY   STATUS    RESTARTS   AGE
pod/toyota-deployment-7b465d6d44-5g767   4644458887903699283   1/1     Running   0          4s
pod/toyota-deployment-7b465d6d44-fwbr4   3523552791452590234   1/1     Running   0          4s
pod/toyota-deployment-7b465d6d44-mhqd8   3470346433990691991   1/1     Running   0          4s

NAME                                         HASHKEY              READY   UP-TO-DATE   AVAILABLE   AGE
deployment.extensions/futurewei-deployment   409069956080056099   3/3     3            3           4s
```

4. Become a regular (non-admin) user and enjoy the reduced power:

As John (taking the reader role):

```bash
root@ip-172-31-27-32:/tmp# be-john
Switched to context "toyota-john-context".
root@ip-172-31-27-32:/tmp
root@ip-172-31-27-32:/tmp# kubectl get pods,deployment
NAME                                    HASHKEY               READY   STATUS    RESTARTS   AGE
toyota-deployment-7b465d6d44-5g767   4644458887903699283   1/1     Running   0          2m43s
toyota-deployment-7b465d6d44-fwbr4   3523552791452590234   1/1     Running   0          2m43s
toyota-deployment-7b465d6d44-mhqd8   3470346433990691991   1/1     Running   0          2m43s
Error from server (Forbidden): deployments.extensions is forbidden: User "john" cannot list resource "deployments" in API group "extensions" in the namespace "default"
```

To delete the deployment, become tenant-admin again.

```bash
root@ip-172-31-27-32:/tmp# be-tenant-admin
Switched to context "toyota-admin-context".
root@ip-172-31-27-32:/tmp
root@ip-172-31-27-32:/tmp# kubectl delete -f ~/bug-bash/arktos-bug-bash/yamls/test_deployment.yaml
deployment.apps "toyota-deployment" deleted
```
