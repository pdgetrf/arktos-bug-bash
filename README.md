# set up access for remote access

## Where's the host?
The host endpoint is in the futurewei.kubeconfig file. It runs in AWS.

## Prepare kubectl
Compile kubectl from arktos master repo

## Get Certs
Call Peng for them. Once certs are obtained, put them in /tmp

## Setup KUBECONFIG
1. export KUBECONFIG=/tmp/futurewei.kubeconfig
2. Copy the futurewei.kubeconfig from this repo to /tmp

## Add Context Aliases
Run add-alias.sh to add the following alias for context switch:

```
alias be-peng='kubectl config use-context futurewei-pengdu-context'
alias be-tenant-admin='kubectl config use-context futurewei-admin-context'
alias be-xiaoning='kubectl config use-context futurewei-xiaoning-context'
```

## Have Fun Testing

As an example:

1. Become the tenant admin (if you have the cert)
```bash
root@ip-172-31-27-32:~/bug-bash/arktos-bug-bash# be-tenant-admin
Switched to context "futurewei-admin-context".
```

2. Create roles and bindings for user:
```bash
root@ip-172-31-27-32:~/bug-bash/arktos-bug-bash# ./create_roles_by_admin.sh
+ kubectl create -f futureweirole-reader.yaml
role.rbac.authorization.k8s.io/futurewei-reader created
+ kubectl create -f futureweirole-pod-reader.yaml
role.rbac.authorization.k8s.io/futureweirole-pod-reader created
+ kubectl create -f futureweirolebinding-pengdu.yaml
rolebinding.rbac.authorization.k8s.io/futureweirolebinding-pengdu created
+ kubectl create -f futureweirolebinding-xiaoning.yaml
rolebinding.rbac.authorization.k8s.io/futureweirolebinding-xiaoning created
```

3. Create a deployment (or a job or whatever resource you want to test):
```bash
root@ip-172-31-27-32:~/bug-bash/arktos-bug-bash# kubectl create -f test_deployment.yaml
deployment.apps/futurewei-deployment created
```

4. Become a regular (non-admin) user and enjoy the reduced power:
As Peng (taking the pod-reader role):
```bash
root@ip-172-31-27-32:~/bug-bash/arktos-bug-bash# be-peng
Switched to context "futurewei-pengdu-context".
root@ip-172-31-27-32:~/bug-bash/arktos-bug-bash#
root@ip-172-31-27-32:~/bug-bash/arktos-bug-bash# kubectl get pods,deployment
NAME                                    HASHKEY               READY   STATUS    RESTARTS   AGE
futurewei-deployment-7b465d6d44-2hp8d   6163652222708500136   1/1     Running   0          56s
futurewei-deployment-7b465d6d44-kj5mc   3906009626040215916   1/1     Running   0          56s
futurewei-deployment-7b465d6d44-nm5dk   2682486539157054401   1/1     Running   0          56s
Error from server (Forbidden): deployments.extensions is forbidden: User "pengdu" cannot list resource "deployments" in API group "extensions" in the namespace "default"
```
As Xiaoning (taking the reader role):
```bash
root@ip-172-31-27-32:~/bug-bash/arktos-bug-bash# be-xiaoning
Switched to context "futurewei-xiaoning-context".
root@ip-172-31-27-32:~/bug-bash/arktos-bug-bash# kubectl get pods,deployment
NAME                                        HASHKEY               READY   STATUS    RESTARTS   AGE
pod/futurewei-deployment-7b465d6d44-2hp8d   6163652222708500136   1/1     Running   0          3m11s
pod/futurewei-deployment-7b465d6d44-kj5mc   3906009626040215916   1/1     Running   0          3m11s
pod/futurewei-deployment-7b465d6d44-nm5dk   2682486539157054401   1/1     Running   0          3m11s

NAME                                         HASHKEY               READY   UP-TO-DATE   AVAILABLE   AGE
deployment.extensions/futurewei-deployment   3670486416904405280   3/3     3            3           3m11s
```
To delete the deployment, become tenant-admin again.

