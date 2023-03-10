### Auth stuff
# Activate service account credentials file in gcloud
gcloud auth activate-service-account --key-file credentials.json

# Set configurations
gcloud config set compute/zone us-central1-c

# List configurations
g config configurations list

# Set project configuration
g config configurations create $project
g config set project $project_id
g config set account $account_email

# Activate a specific configuration
g config configurations activate $project

# Run a single command with specific configuration
g auth list --configuration=$config_name

# How to impersonate a service account for gcloud.
# If using this for SDK access, review https://googleapis.dev/python/google-api-core/latest/client_options.html.Impersonating 
# Found this on https://groups.google.com/g/cloud-speech-discuss/c/wBjDFpPW2rs?pli=1.
# Two ways of accomplishing this:
# 1. Download a service account credential
# 2. Set the GOOGLE_APPLICATION_CREDENTIALS env variable pointing to the .json
export GOOGLE_APPLICATION_CREDENTIALS="~/.Downloads/access_key.json"
# 3. Get your auth token via:
gcloud auth application-default print-access-token

# 1. Download a service account credential
# 2. Run:
gcloud auth activate-service-account --key-file="~/.Downloads/access_key.json"
# 3. Get your auth token via:
gcloud auth print-access-token

# When developing locally use below command to create a credentials file that can be picked up by client libraries.
gcloud auth application-default login

# gcloud works a bit different than AWS CLI. It does a number of admin tasks like managing projects where it requires its own project ID and its own auth token. It uses oauth2 to obtain credentials when you first setup gcloud. In order to run API queries successfully, you need an API key or SA key for your own project, not what gcloud uses.

## Resource Manager
# View list of Org policies that are eanbled on an organization, folder, or project
gcloud alpha resource-manager org-policies list --organization=orgidhere

## Compute Engine
# View project-wide metadata
gcloud compute project-info describe

# Add project-wide SSH key
gcloud compute project-info add-metadata --metadata-from-file ssh-keys=[LIST_PATH]

# Block project-wide SSH keys
gcloud compute instances add-metadata [INSTANCE_NAME] --metadata block-project-ssh-keys=TRUE

# Add instance-wide SSH key
gcloud compute instances add-metadata [INSTANCE_NAME] --metadata-from-file ssh-keys=[LIST_PATH]

# Show firewall rules with specific prefix
gcloud compute firewall-rules list --project=<Project-name> --filter="NAME ~ '^k8s-'"

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

# List instance information for an internal IP
gcloud compute instances list --filter="networkInterfaces[].networkIP:10.0.0.5"

# Move instance to a new zone
gcloud compute instances move

# Access instance from Cloud Shell via gcloud
gcloud beta compute ssh --zone "us-central1-a" "instance-1"  --project $PROJECT_ID

# Autoscaling rolling update
gcloud beta compute instance-groups managed rolling-action [replace,restart,start-update,stop-proactive-update]
### Global project config
# Show quota stuff
gcloud compute project-info describe --project ${PROJECT_ID}
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

# Authenticate to specific cluster's API endpoint
gcloud container clusters get-credentials anthos-sample-cluster1 --region us-central1-c

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

# Create a deployment for your pods Use EOT or EOF to parse data from from stdin
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

# Apply a network policy to control pod to pod communication between namespaces
cat <<EOT >> kubectl create -f
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  namespace: secondary
  name: deny-from-other-namespaces
spec:
  podSelector:
    matchlabels:
  ingress:
  - from:
    - podSelector: {}
EOT

# Apply a network policy that denies all ingress and egress traffic
cat <<EOT >> kubectl create -f
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: default-deny
spec:
  podSelector: {}
  policyTypes:
  - Egress
  - Ingress
EOT

# Create a k8s RBAC role
cat <<EOT >> kubectl create -f
apiVersion: v1
kind: Namespace
metadata:
  name: product-namespace
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: product-namespace
  name: pod-reader
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
# This role binding allows "frank" who belongs to the pod-readers group to read pods in the "default" namespace
kind: RoleBinding
metadata:
  name: read-pods
  namespace: product-namespace
subjects:
# G Suite Google Group
- kind: Group
  name: pod-readers@example.com
roleRef:
  kind: Role # this must be Role or ClusterRole
  name: pod-reader # this must match the name of the Role
apiGroup: rbac.authorization.k8s.io
EOT

# Pod security policy
cat <<EOT >> kubectl create -f
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: restricted
  annotations:
    seccomp.security.alpha.kubernetes.io/allowedProfileNames: 'docker/default'
    apparmor.security.beta.kubernetes.io/allowedProfileNames: 'runtime/default'
    seccomp.security.alpha.kubernetes.io/defaultProfileName:  'docker/default'
    apparmor.security.beta.kubernetes.io/defaultProfileName:  'runtime/default'
spec:
  privileged: false
  # Required to prevent escalations to root.
  allowPrivilegeEscalation: false
  # This is redundant with non-root + disallow privilege escalation,
  # but we can provide it for defense in depth.
  requiredDropCapabilities:
    - ALL
  # Allow core volume types.
  volumes:
    - 'configMap'
    - 'emptyDir'
    - 'projected'
    - 'secret'
    - 'downwardAPI'
    # Assume that persistentVolumes set up by the cluster admin are safe to use.
    - 'persistentVolumeClaim'
  hostNetwork: false
  hostIPC: false
  hostPID: false
  runAsUser:
    # Require the container to run without root privileges.
    rule: 'MustRunAsNonRoot'
  seLinux:
    # This policy assumes the nodes are using AppArmor rather than SELinux.
    rule: 'RunAsAny'
  supplementalGroups:
    rule: 'MustRunAs'
    ranges:
      # Forbid adding the root group.
      - min: 1
        max: 65535
  fsGroup:
    rule: 'MustRunAs'
    ranges:
      # Forbid adding the root group.
      - min: 1
        max: 65535
  readOnlyRootFilesystem: false
EOT

# Cloud Logging query for pod logs:
```
resource.type="k8s_container"
resource.labels.project_id="$PROJECT_ID"
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

# Set Kubernetes namespace
kubectl config set-context --current --namespace=boa

# Use kubens and kubectx to manage namespaces and clusters/contexts
kubens list
kubectx

# Show namespace name in PS1 prompt
kubeon
source "/Users/$USER/code/github.com/brew/opt/kube-ps1/share/kube-ps1.sh"

# View current context
k config get-contexts

# Rename context
k config rename-context $old_context_name $new_context_name

# Show pods with labels
k -n istio-system get pods -l app=istiod --show-labels -o wide

# Create a network testing pod
# Another good one is network-multitool container image: https://hub.docker.com/r/praqma/network-multitool/
kubectl apply -f https://k8s.io/examples/admin/dns/dnsutils.yaml
cat <<EOT >> kubectl create -f
apiVersion: v1
kind: Pod
metadata:
  name: dnsutils
  namespace: default
spec:
  containers:
  - name: dnsutils
    image: gcr.io/kubernetes-e2e-test-images/dnsutils:1.3
    command:
      - sleep
      - "3600"
    imagePullPolicy: IfNotPresent
  restartPolicy: Always
EOT

# Test networking of the environment
kubectl exec -i -t dnsutils -- nslookup kubernetes.default

## IAM
# Search for users bound to specific role
g beta asset search-all-iam-policies \
    --query policy:"roles/test-role" \
    --project $PROJECT_ID \
    --format json

# View recommendations from the Recommender service
g recommender recommendations list \
    --project=${PROJECT_ID} \
    --location=global \
    --recommender=google.iam.policy.Recommender \
    --format=json

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

# Filter IAM policy bindings based on a member's email address
gcloud projects get-iam-policy $PROJECT_ID \
    --flatten="bindings[].members" \
    --filter="bindings.members=serviceAccount:service-012345678901@gcp-sa-vpcaccess.iam.gserviceaccount.com"

## Anthos
# Verify config using nomos
nomos vet --source-format=unstructured

## CloudBuild
# Run a build locally
cloud-build-local --config=cloudbuild.yaml --dryrun=false .

# Trigger a build from cloudbuild.yaml
g builds submit --config=cloudbuild.yaml

# Export resources into Terraform configurations
gcloud beta resource-config bulk-export \
    --resource-format terraform \
    --resource-types=storage.cnrm.cloud.google.com/StorageBucket,ComputeInstance

# Access specific Google API via Rest
curl -X GET -H "Content-Type: application/json; charset=utf-8" -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" https://composer.googleapis.com//v1beta1/projects/${PROJECT_ID}/locations/us-central1/environments/?alt=json

# log HTTP calls in gcloud
gcloud --log-http

# Tunnel through IAP
gcloud compute start-iap-tunnel instance-1 8888 --local-host-port=localhost:8888
