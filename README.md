# Kubernetes
# Create deploy and service for mongo
# create Persistent volume and PVC to claim storage
# connect the app to db
![](https://github.com/khanmaster/SRE_K8_deployment/blob/main/k8.png)


https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#-em-undo-em-

kubectl create php-apache --image=gcr.io/google containers/hpa-example --requests=cpu=500m memory=500M --expose --port=80

### CronJobs Automated Tasks

- Cron schedule syntax
```
#      ┌────────────────── timezone (optional)
#      |      ┌───────────── minute (0 - 59)
#      |      │ ┌───────────── hour (0 - 23)
#      |      │ │ ┌───────────── day of the month (1 - 31)
#      |      │ │ │ ┌───────────── month (1 - 12)
#      |      │ │ │ │ ┌───────────── day of the week (0 - 6) (Sunday to Saturday;
#      |      │ │ │ │ │                                   7 is also Sunday on some systems)
#      |      │ │ │ │ │
#      |      │ │ │ │ │
# CRON_TZ=UTC * * * * *
```
- Let's break it down
```
Entry	Description	Equivalent to
@yearly (or @annually)	Run once a year at midnight of 1 January	0 0 1 1 *
@monthly	Run once a month at midnight of the first day of the month	0 0 1 * *
@weekly	Run once a week at midnight on Sunday morning	0 0 * * 0
@daily (or @midnight)	Run once a day at midnight	0 0 * * *
@hourly	Run once an hour at the beginning of the hour	0 * * * *
```
- Use Case:
- For example, the line below states that the task must be started every Friday at midnight, as well as on the 13th of each month at midnight(in UTC):

- `CRON_TZ=UTC 0 0 13 * 5`














- Create a PVC Persistent Volume Claim  for Mongo
```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mongo-db
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 256Mi
```
- Create a Service for Mongo
```
apiVersion: v1
kind: Service
metadata:
  name: mongo
spec:
  selector:
    app: mongo
  ports:
    - port: 27017
      targetPort: 27017
```
- Create a Deployment for Mongo
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mongo
spec:
  selector:
    matchLabels:
      app: mongo
  replicas: 1
  template:
    metadata:
      labels:
        app: mongo
    spec:
      containers:
        - name: mongo
          image: mongo
          ports:
            - containerPort: 27017
          volumeMounts:
            - name: storage
              mountPath: /data/db
      volumes:
        - name: storage
          persistentVolumeClaim:
            claimName: mongo-db

```
- Create Deployment for Nodeapp
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: node
spec:
  selector:
    matchLabels:
      app: node
  replicas: 3
  template: 
    metadata:
      labels:
        app: node
    spec:
      containers:
        - name: node
          image: ahskhan/eng89_node_prod
          
          ports:
            - containerPort: 3000
          env:
            - name: DB_HOST
              value: mongodb://mongo:27017/posts
          
          imagePullPolicy: Always

          resources:
            limits:
              memory: 512Mi
              cpu: "1"
            requests:
              memory: 256Mi
              cpu: "0.2"
```
- Create a LoadBalancer Service for the app
```
---
apiVersion: v1
kind: Service
metadata:
  name: node
spec:
  selector:
    app: node
  ports:
    - port: 3000
      targetPort: 3000
  type: LoadBalancer    

```
- Create an Horizental Autoscaling Group
```
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler

metadata:
  name: sparta-node-app-deploy
  namespace: default
  
spec:
  maxReplicas: 9
  minReplicas: 1
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: node
  targetCPUUtilizationPercentage: 50

```
- Create a cronjob
```
apiVersion: batch/v1
kind: CronJob
metadata:
  name: eng89
spec:
  schedule: "*/1 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: eng89
            image: busybox
            imagePullPolicy: IfNotPresent
            command:
            - /bin/sh
            - -c
            - date; echo thank you for using cronjob

          restartPolicy: OnFailure

```
- kubectl apply -f cron-job.yml
- kubectl get cronjob
- kubectl get job --watch copy name and paste on next command
- pods=$(kubectl get pods --selector=job-name=eng89-27163575 --output=jsonpath={.items[*].metadata.name})
- kubectl logs $pods
