### Auth stuff
# Activate service account credentials file in gcloud
gcloud auth activate-service-account --key-file credentials.json

# Set configurations
gcloud config set compute/zone us-central1-c

# View project-wide metadata
gcloud compute project-info describe

### Cloud Storage
# Create bucket
gsutil mb -l US gs://$DEVSHELL_PROJECT_ID

# Copy stuff to a bucket
gsutil cp gs://cloud-training/gcpfci/my-excellent-blog.png > my-excellent-blog.png
gsutil cp my-excellent-blog.png gs://$DEVSHELL_PROJECT_ID/my-excellent-blog.png

# Get object ACL
gsutil acl get gs://$BUCKET_NAME_1/setup.html

# Make an object private
gsutil acl set private gs://$BUCKET_NAME_1/setup.html

# Make an object publicly readable
gsutil acl ch -u AllUsers:R gs://$BUCKET_NAME_1/setup.html

# Sync directory to GCS bucket
gsutil rsync -r ./firstlevel gs://$BUCKET_NAME_1/firstlevel/

# Create a bucket with retention
gsutil mb -l us-west2 -s coldline --retention 10y gs://logs-archive

### VPC networking
# Show VPC networks
gcloud compute networks list

# Show subnets sorted by VPC network
gcloud compute networks subnets list --sort-by=NETWORK

# Create firewall rule
gcloud compute firewall-rules create privatenet-allow-icmp-ssh-rdp --direction=INGRESS --priority=1000 --network=privatenet --action=ALLOW --rules=icmp,tcp:22,tcp:3389 --source-ranges=0.0.0.0/0

# Show firewall rules
gcloud compute firewall-rules list --sort-by=NETWORK

### Compute Engine
# Create an instance (parameters: project, region, zone, subnetwork, machine type, disk options, image, IP options)
gcloud compute instances create [instance-name]
gcloud compute instances create privatenet-us-vm --zone=us-central1-c --machine-type=f1-micro --subnet=privatesubnet-us --image-family=debian-10 --image-project=debian-cloud --boot-disk-size=10GB --boot-disk-type=pd-standard --boot-disk-device-name=privatenet-us-vm

# List instances in specific zone using filters
gcloud compute instances list --filter="zone:('us-central1-a','europe-west1-d')"

# Move instance to a new zone
gcloud compute instances move

# Autoscaling rolling update
gcloud beta compute instance-groups managed rolling-action [replace,restart,start-update,stop-proactive-update]
### Global project config
# Show quota stuff
gcloud compute project-info describe --project training-307022
gcloud compute regions describe us-central1

### GKE - https://kubernetes.io/docs/reference/kubectl/cheatsheet/
# Create a cluster
gcloud container clusters create k1 --zone us-east1-b --num-nodes=2

# Set kubeconfig for specific cluster
gcloud container clusters get-credentials k1

# Resize a GKE cluster
gcloud container clusters resize CLUSTER_NAME --node-pool POOL_NAME     --num-nodes NUM_NODES

# Create a pod
kubectl run nginx --image=nginx:1.15.7

# Get info on a pod
kubectl get pods -l "app=nginx" -o yaml

# Get stuff using JSONPath
kubectl get pod/nginx -o jsonpath='{.spec.containers[].image}'

# Apply changes from yaml file
kubectl apply -f pod.yml

# Create a deployment for your pods
cat <<EOT >> kubectl create -f
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
EOT

# Expose a pod to a service:
kubectl expose deployments nginx --port-80 --type=LoadBalancer

# Scale / autoscale a pod
kubectl scale nginx --replicas=3
# min 10, max 15 pods above 80%
kubectl autoscale nginx --min=10 --max=15 --cpu=80

