# Minikube single node Kubernetes cluster setup on AWS EC2 18.04LTS Ubuntu
## Installation of Minikube on EC2 Ubuntu 18.04 LTS
### 

**pre-requesits**
- AMI Ubuntu Server 18.04 LTS (HVM), SSD Volume Type
- Instance Type t2.medium
- Storage 8 GB (gp2)
- Security Group Name: k8
-  Security Group – SSH, `from your ip/0.0.0.0/0`
- Key Pair Create your own keypair.

#### SSH into EC2 instance
- Run `sudo apt-get update -y`
- Run `sudo apt-get upgrade -y`

#### Install kubectl 
```
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
```
- Make it executable `chmod +x ./kubectl`
- Move it to default location`sudo mv ./kubectl /usr/local/bin/kubectl`


#### Moving onto installing Docker
- `sudo apt-get update && sudo apt-get install docker.io -y`
- `docker run -d -p 3000:5000 ahskhan/k8-app`

- Check docker installation `docker version`
```
root@ip-172-31-25-115:~# docker version
Client:
 Version:           20.10.7
 API version:       1.41
 Go version:        go1.13.8
 Git commit:        20.10.7-0ubuntu1~18.04.2
 Built:             Fri Oct  1 21:47:31 2021
 OS/Arch:           linux/amd64
 Context:           default
 Experimental:      true

Server:
 Engine:
  Version:          20.10.7
  API version:      1.41 (minimum version 1.12)
  Go version:       go1.13.8
  Git commit:       20.10.7-0ubuntu1~18.04.2
  Built:            Fri Oct  1 13:28:27 2021
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          1.5.2-0ubuntu1~18.04.3
  GitCommit:
 runc:
  Version:          1.0.0~rc95-0ubuntu1~18.04.2
  GitCommit:
 docker-init:
  Version:          0.19.0
  GitCommit:
```
#### Let's install Minikube on AWS EC2 
- We will get this done one go
```
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/
```
- check version`minikube version`
- `minikube version: v1.23.2`
#### Launching minikube
- Change to root user `sudo -i`
- Start Minikube
-  We are going to use the –vm-driver=none switch.
-   The rationale is we don’t want to install a Hypervisor like VirtualBox on the AWS instance, we just want minikube to run using the host
- Start command `minikube start --vm-driver=none`
- Status check `minikube staus`
- Expected output
```
minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured
```
**The default node port(external port) range for Kubernetes is 30000 - 32767**
- Add this range to you security group to allow public access

#### Testing  
- Let's create a pod 
-  `kubectl run sparta-app --image=ahskhan/eng89_node_prod --port=3000`
-  Check if it's created and running
-  `kubectl get pods`
###### Expose it on public ip
-  `kubectl expose pod sparta-app --type=NodePort`
-  check `kubect get svc`

### Highly Available and Scalable Deployment
- `kubectl create deployment sparta-app --image=image-name --port=80 --replicas=3`
- Deployment with 3 Pods
```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  annotations:
    deployment.kubernetes.io/revision: "1"
  creationTimestamp: "2021-10-20T14:45:04Z"
  generation: 1
  labels:
    app: k8-app
  name: k8-app
  namespace: default
  resourceVersion: "4824"
  uid: e6f7de78-19e5-4262-b62c-ebdce4d4677d
spec:
  progressDeadlineSeconds: 600
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app: k8-app
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: k8-app
    spec:
      containers:
      - image: ahskhan/k8-app
        imagePullPolicy: Always
        name: k8-app
        ports:
        - containerPort: 5000
          protocol: TCP
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 30
status:
  availableReplicas: 1
  conditions:
  - lastTransitionTime: "2021-10-20T14:45:07Z"
    lastUpdateTime: "2021-10-20T14:45:07Z"
    message: Deployment has minimum availability.
    reason: MinimumReplicasAvailable
    status: "True"
    type: Available
  - lastTransitionTime: "2021-10-20T14:45:04Z"
    lastUpdateTime: "2021-10-20T14:45:07Z"
    message: ReplicaSet "k8-app-648685dfd" has successfully progressed.
    reason: NewReplicaSetAvailable
    status: "True"
    type: Progressing
  observedGeneration: 1
  readyReplicas: 1
  replicas: 1
  updatedReplicas: 1

```
- `kubectl expose deployment sparta-app --type=LoadBalancer`
```yml
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: "2021-10-20T14:45:23Z"
  labels:
    app: k8-app
  name: k8-app
  namespace: default
  resourceVersion: "4839"
  uid: 91d66648-6de1-438f-94c1-42e92cbb1763
spec:
  clusterIP: 10.99.60.4
  clusterIPs:
  - 10.99.60.4
  externalTrafficPolicy: Cluster
  internalTrafficPolicy: Cluster
  ipFamilies:
  - IPv4
  ipFamilyPolicy: SingleStack
  ports:
  - nodePort: 31474
    port: 5000
    protocol: TCP
    targetPort: 5000
  selector:
    app: k8-app
  sessionAffinity: None
  type: NodePort
status:
  loadBalancer: {}
```
- ` kubectl create deployment sparta-app --image=image-name --port=5000`
  