# List installed charts
helm ls -n istio-system

# Add stable repo
helm repo add stable https://charts.helm.sh/stable

# Helm repo update
helm repo update

# Install istio from helm release
helm install istiod manifests/charts/istio-control/istio-discovery -n istio-system

# Search for charts
helm search hub $chartname

# Install chart from helm
helm install $releasename $chartname -n $namespace

# Get status of a chart
helm status istio-base -n istio-system

# Get chart's manifest
helm get manifest $chart_name
