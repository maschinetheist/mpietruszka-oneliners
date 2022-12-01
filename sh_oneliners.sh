# Install PIP on cygwin's python
python -m ensurepip

# Ansible stuff
# Run sudo command:
ansible 10.210.37.12* -a "systemctl disable firewalld" --become --become-user=root -K
ansible 10.210.37.12* -m $module # http://docs.ansible.com/ansible/list_of_all_modules.html
ansible-playbook projects/common/vim.yml --extra-vars='ansible_become_pass=password'

# Ansible-playbook deploy stuff using root and vault (also use local hosts file)
ansible-playbook lab_deploy.yml --ask-vault-pass -i hosts -u root

# Ansible install $package
ansible lab-ose2 -m yum -a "name=chrony state=latest" --become -K

# Ensure package is enabled
ansible lab-ose2 -m systemd -a "name=chronyd state=started enabled=yes" --become -K

# Ansible-vault
ansible-vault decrypt lab_vars_pass.yml
ansible-vault encrypt lab_vars_pass.yml
echo -n 'password' | ansible-vault encrypt_string --vault-id ldap_bind_password --stdin-name 'ldap_bind_password'

# Find what is listening on a particular port
netstat --tcp --udp -n --listening --program | grep $port

# Iptables
# Moving rules around
iptables-save > iptables.test
vim iptiables.test # move rules around
iptables-restore < iptables.test
# Block tcp/80
-A INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j REJECT
# Iptables block source IP
-A INPUT -p tcp -m state --state NEW -m tcp -s 192.168.1.2 --dport 80 -j REJECT
# Iptables block destination IP
-A OUTPUT -p tcp -m state --state NEW -m tcp -d 192.168.1.2 --dport 80 -j DROP
# View rules
iptables -L --line-numbers -v
# Delete rules
iptables -D INPUT $rule_num # substitute $rule_num for actual rule if needed
# Display rules as commands (similar to show config | display-set in JunOS)
iptables -S

# Align text in vi/vim to =
:'<,'>!column -t # Basically visually select text and run column -t as external command on selection

# Create a 3GB+ file:
dd if=/dev/zero of=/tmp/test bs=1024 count=3600000

# Increase the priority of a process
ps axl | grep $pid
sudo renice -10 -p $pid

# Show ls long listing without user:group information
find . -type f | egrep -v '\.[common|git]+' | xargs ls -god

# Generate a password using python
python -c "from passlib.hash import sha512_crypt; import getpass; print sha512_crypt.encrypt(getpass.getpass())"

# Run ORT/QA scripts via Puppet in production environment
grep puppet /opt/opensystems/bin/autorunortchecks_firecall.sh
tsshbatch.py -xsEK -P "/opt/opensystems/bin/ortcheck.sh /home/${RUN_USER}" -H "${HOSTS}" sudo puppet  resource exec "/home/${RUN_USER}/ortcheck.sh" user=root logoutput=true | tee /home/${RUN_USER}/ort.${D}
#For some reason puppet way of doing things creates a ASCII file with escape characters 

# Bonding options for bonded NICs
BONDING_OPTS="mode=1 miimon=100 downdelay=200 \
updelay=200 primary=eth1 use_carrier=1 primary_reselect=2 " 

# curl replacement for nc/telnet
curk -vk $ip:$port

# GPFS block size
/usr/lpp/mmfs/bin/mmlsfs all_local -B | tee /tmp/gpfs.blocksize
grep Block /tmp/gpfs.blocksize

# Show GPFS mounts
nmlsmount gpfs_crs -L

# Disable huge pages on Oracle DB servers by adding kernel parameters in Grub2:
grubby --update-kernel=ALL --args="transparent_hugepage=never"

# Deploy specific puppet hash
puppet agent -t --tags variable_filesystems_nas_v2 --no-noop

# Skip particular puppet tags
puppet agent –t --skip_tags Infosec_sudoers

# Put a running process in the background
ps -ef | grep $job # get pid
# ctrl + z on running process
bg

# Print thread count for processes
ps -eLf | grep hdp | awk '{print $2}' | sort | uniq -c

# View overcommit memory kernel parameter
sysctl vm.overcommit_memory
grep -i commit /proc/meminfo

# VirtualEnv
# Enable python3.5 virtualenv
virtualenv -p /usr/local/bin/python3.5 venv
source venv/bin/activate
pip install requests
deactivate

# Verify available entropy in the kernel
cat /proc/sys/kernel/random/entropy_avail
egrep -i 'RDRAND|RDSEED' /proc/cpuinfo

# Expand tabs to spaces
expand
unexpand

# Line numbers
nl

# Show files in a directory without symbolic links
find /etc/pam.d -mindepth 1 ! -type l

# Show symbolic links in a directory
find /etc/pam.d -type l

# Autodoc in Sphinx
sphinx-apidoc -f -o source/ ../bin && make html

# Git remove last commit
git reset --hard HEAD^

# Git remove last two commits
git reset --hard HEAD~2

# Git copy from one branch to another (from development to master)
git diff --stat $branch
git checkout --merge $branch $file
git diff --stat $branch

# Git sync branch from master
git checkout master
git pull origin master
git merge development

# Change Linux I/O scheduler
# choices are noop, anticipatory, deadline, cfq
echo ${scheduler_name} > /sys/block/${device_name}/queue/scheduler

# Adjust udev rules
udevadm control --reload-rules
udevadm trigger --type=devices --action=change

# Restore SELinux contexts on home directories
matchpathcon /home/$username
restorecon -Rv /home/$username

# View umask in symbolic notation (u=rwx,g=rwx,o=rwx)
umask -S

# Remove duplicate packages in YUM
package-cleanup --dupes | sort > rpm.txt
# Edit the rpm.txt file and remove new version packages
rpm -e $(cat rpm.txt) --nodeps --justdb

# View linux namespaces (requires util-linux package)
lsns
ls /proc/$pid/ns/pid

# Run IOZone tests
iozone -l 1 -r 1M -s 1G -+n -i 0 -i 1 -i 2 -F /dev/mapper/MAPRLUKSDISK1

# Write multiple secrets to vault
echo <<EOT >> secrets.json
{ "username": "Administrator@vsphere.local", "password": "admin" }
EOT
vault write secrets/blah @secrets.json
vault read secrets/blah
# Or...
vault write secrets/blah/username value="root"
vault write secrets/blah/password value="password"

# Sealing and unsealing a vault
vault seal
vault status
vault unseal # enter unseal key

# Strace
strace -p $pid
strace $application
strace -e read,write $application
blktrace
blkparse

# Run FIO disk testing software
fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test --filename=test --bs=4k --iodepth=64 --size=4G --readwrite=randrw --rwmixread=75

# SSL
# Verify certificate
openssl x509 -in corp_dev.pem -noout -text

# Create a cert with private key and CSR
openssl genrsa -out private/consul.node.chi.consul.key 4096
openssl req -new -extensions usr_cert -sha256 -subj "/C=US/ST=Illinois/L=Chicago/O=LOL/CN=consul.node.chi.consul" -key private/consul.node.chi.consul.key -out newcerts/consul.node.chi.consul.csr
openssl x509 -signkey private/consul.node.chi.consul.key -req -days 3650 -in newcerts/consul.node.chi.consul.csr -out certs/consul.node.chi.consul.crt

# Verify certificate validity
openssl s_client -connect google.com:443

# See who is locked in AD LDAP:
ldapsearch -x -W -LLL -h some.domain.com -D $(whoami)@some.domain.com -b DC=some,DC=domain,DC=com cn=some_user | grep lock

# Sort files/directories by size
du -sh * | sort -r -n -k7

# Check if lines in a file are in another file
while read line; do grep $line 99-oracle-asmdevices.rules ; done < luns

# Find *.py files in a specific directory using fd
fd "^*.py$" some_folder/

# Exclude files in fd search
fd -H -E .git
fd -E '*.bak'
# Also add files to ~/.fdignore

# 3x streams
# 0 - input - stdin
# 1 - output - stdout
# 2 - output - stderr
# 2>&1 (stderr (2) to pointer of stdout (1))
program 2>&1 | tee build.log

# Grab something from a log file and strip double quotes using awk
grep -A 2 "Registering" tmp/register-ami.log | awk '/ami-/ { $2=$2; gsub("\"",""); print $2 }'

# Show when a server was built
lsfact -f tu_born_on_date | grep 2019-05 | sort -k2 -t,

# Iperf3
# server:
iperf3 -s
# client: 
iperf3 -c 10.208.45.236 5201 -d # add -d to bidirectional testing

# Show memory usage per process
/opt/opensystems/bin/smem -tk

# Check for open ports without telnet or netcat
cat < /dev/tcp/10.114.4.252/22
cat < /dev/udp/10.114.4.252/53

# Wget ask for credentials
wget --user "mpietru" --ask-password ${url}

# Grep recursively through a directory of c files and headers
grep --include=\*.{c,h} -rnwl '/path/to/somewhere' -e "pattern"

# Rename multiple files using find and rename commands
find . -type f -name '*.yml' -exec rename 's/\.yml/.yaml/g' '{}' \;
