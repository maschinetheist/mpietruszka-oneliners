# Run a docker image (for more information see: https://docs.docker.com/engine/reference/run)
# -t allocate a pseudo-tty
# -i keep STDIN open
# -a attached to STDIN, STDOUT, STDERR
# -d detached (foreground is default)
# -p port mapping [local_port]:[container_port]
# --network="bridge" select a network
# -v=[src]:[dst] mount a local volume
# -m memory limitation
docker run -d -ti $image_name /bin/bash
docker run -ti -p 8080:8080 $image_name:$tag
docker run -d -p 8080:8080 $image_name:$tag

# Attach a container as a different user
docker exec -it --user nginx $image_name /bin/bash

# Attach to a running docker image
docker exec -ti $image_id /bin/bash

# Log into a private repository
docker login -u $username -e $email docker.io
# You can attach to an instance if it was started with /bin/bash; otherwise need to run 'exec' to start a new instance inside of the container

# Build image from Dockerfile
docker build -t $image_name:$tag .

# Push an image
docker tag $image_name docker.io/$image_name
docker push docker.io/$image_name

# Search registry
docker search $registry:$port/$image

# Inspect a container and its details
docker inspect $container_id
docker info $container_id

# Export an image to a tarball
docker save -o $image.img $image

# Use jsonlint to view json metadata file within the tarball
jsonlint -f json | less -S

# Mount local directory inside of a container [local_dir]:[container_dir]
docker run -ti -p 10080:8080 -v /srv:/srv $image_id $container_id
# You will need to add SELinux contexts to the directory to allow reading
chcon -t svirt_sandbox_file_t /srv/test
semanage fcontext -l
semanage fcontext -a -t httpd_sys_content "/srv(/.*)?"
restore -R -v /srv
# chcon is temporary
# semanage is permanent

# Print out docker container logs (container's STDOUT)
docker logs $container_id

# Inspect storage of a container
docker inspect -f '{{ .Mounts }}' $container

# Run container on Docker Swarm cluster with shared storage
docker run -dit --volume-driver=nfs -v $nfs_server:/common:/common --name $container_name alpine /bin/sh
