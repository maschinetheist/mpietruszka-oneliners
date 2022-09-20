# List listening TCP ports
lsof -iTCP -sTCP:LISTEN

# List TCP connections
netstat -ap TCP

# List services/daemons
launchctl list 

# Describe services/daemons
launchctl list com.apple.corespotlightd
launchctl describe <pid>

# Reload service/daemon
sudo launchctl [stop|start] com.apple.Spotlight
