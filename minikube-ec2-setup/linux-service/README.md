# Linux Service
## Creating Linux Service
### Creating .service file
#### Creating .sh file to launch the service at boot time

- The aim to restart Kubernetes Cluster and launch the K8 deployment at boot time when the autoscaling group triggers
- In our case the K8 cluster runnning inside Minikube Master Node
- We need start Minikube at boot time so the K8 deployment and services go live

### Let's create a service
- `sudo nano /etc/systemd/k8_svc.service`

- `sudo nano k8_srv.service`

```
[Unit]
Description=Start Minikube and K8 Service
After=default.target
[Service]
ExecStart=/home/ubuntu/service_script.sh
[Install]
WantedBy=default.target
```

- Let's create our scrip now
```
#!/bin/bash



echo $(date) >> /home/ubuntu/service.log
nano shahrukh_srv.service
```
- Let's create our script and allow permession
  
- `sudo nano service_script.sh`

- `chmod a+x service_script.sh`

```
docker run --name=k8 -d -p 5000:5000 ahskhan/k8-app
docker run --name=sparta-nginx -d -p 3000:80 ahskhan/nginx-app:v4
```

```bash
#!/bin/bash
#db needs to exit before creating the DB_HOST
# if DB_HOST exists do not create
# else create DB_HOST=db-ip
# if npm == "running":

# google duck.dns to pull ip of any ec2

    kill pm2 all
sudo apt update -y
sudo apt install httpd -y
sudo systemctl start httpd
sudo systemctl enable httpd
echo "<h1>DevOps tomcat testing with user-data from $(hostname -f)</h1>" > /var/www/html/index.html
```
