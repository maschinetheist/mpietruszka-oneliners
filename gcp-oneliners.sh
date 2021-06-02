### Auth stuff
# Activate service account credentials file in gcloud
gcloud auth activate-service-account --key-file credentials.json

# Set configurations
gcloud config set compute/zone us-central1-c

## Compute Engine
# View project-wide metadata
gcloud compute project-info describe

# Add project-wide SSH key
gcloud compute project-info add-metadata --metadata-from-file ssh-keys=[LIST_PATH]

# Block project-wide SSH keys
gcloud compute instances add-metadata [INSTANCE_NAME] --metadata block-project-ssh-keys=TRUE

# Add instance-wide SSH key
gcloud compute instances add-metadata [INSTANCE_NAME] --metadata-from-file ssh-keys=[LIST_PATH]

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

# Access instance from Cloud Shell via gcloud
gcloud beta compute ssh --zone "us-central1-a" "instance-1"  --project "sada-mpietruszka-dev"

# Autoscaling rolling update
gcloud beta compute instance-groups managed rolling-action [replace,restart,start-update,stop-proactive-update]
### Global project config
# Show quota stuff
gcloud compute project-info describe --project training-307022
gcloud compute regions describe us-central1

# Pass startup-script metadata key/value to an instance
gcloud compute instances add-metadata instance-1 --metadata=startup-script='#! /bin/bash
apt-get update
apt-get install -y apache2
cat <<EOF > /var/www/index.html
<html><body><h1>Hello World</h1>
<p>This page was created from a simple startup script!</p>
</body></html>' --zone us-central1-a

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

# Cloud Logging query for pod logs:
```
resource.type="k8s_container"
resource.labels.project_id="sada-mpietruszka-dev"
resource.labels.location="us-central1-a"
resource.labels.cluster_name="k1"
resource.labels.namespace_name="default"
labels.k8s-pod/app="flask"
```

# Expose a pod to a service:
kubectl expose deployments nginx --port-80 --type=LoadBalancer

# Scale / autoscale a pod
kubectl scale nginx --replicas=3
# min 10, max 15 pods above 80%
kubectl autoscale nginx --min=10 --max=15 --cpu=80

# Get pod events
kubectl get events
kubectl describe pods/$pod_name

## IAM
# Create SA (service account)
gcloud iam service-accounts create NAME \
    --description="DESCRIPTION" \
    --display-name="DISPLAY_NAME"

# Grant your service account an IAM role on your project (let's say that your Compute Engine instance with this SA wants to call a particular Google API, like Pub/Sub)
gcloud [projects|organizations] add-iam-policy-binding PROJECT_ID \
    --member "serviceAccount:[NAME]@[PROJECT_ID].iam.gserviceaccount.com" \
    --role "roles/ROLE"

# Revoke a role from a user
gcloud [projects|organizations] remove-iam-policy-binding RESOURCE --member=member --role=role-id

# Allow users to impersonate service account (need to grant a user the Service Account User role) on the service account
gcloud iam service-accounts add-iam-policy-binding [SERVICE_ACCOUNT_ID]@[PROJECT_ID].iam.gserviceaccount.com \
    --member="user:USER_EMAIL" \ # This will typically be in the member-type:id format
    --role="roles/iam.serviceAccountUser"

# Generate access key for a service account
gcloud iam service-accounts keys create keyfile.json --iam-account "[NAME]@[PROJECT_ID].iam.gserviceaccount.com"
gcloud auth activate-service-account ACCOUNT --key-file=KEY_FILE
gcloud auth print-access-token
