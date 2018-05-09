# Glusterd2-container-source

Build docker image from glusterd2 source 
## Build 

if you want to build docker image  from different branch of glusterd2

edit following section in Dockerfile

### glusterd2

```
    GD2_BRANCH="master"
```

### Buid docker image

Build docker image from source
```
    #docker build . -t <image_name:version>
```


## Run

run docker container

Ensure the following directories are created on the host where docker is running:

    /etc/glusterfs
    /var/lib/glusterd2
    /var/log/glusterfs Also, ensure they are empty to avoid any conflicts. Now run the following command:

by default glusterd2 starts with the configuration present in /etc/glusterd2/glusterd2.toml

* run with default configuration

```
    #docker run  -v /etc/glusterfs:/etc/glusterfs:z -v /var/lib/glusterd2:/var/lib/glusterd2:z -v /var/log/glusterfs:/var/log/glusterfs:z -v /sys/fs/cgroup:/sys/fs/cgroup:ro -d --privileged=true --net=host -v /dev/:/dev <image_name:version>
```

* run with new  configuration file

    add new configuration file to the docker container and run docker container with new configuration

```
    #docker run -v /etc/glusterfs:/etc/glusterfs:z -v /var/lib/glusterd2:/var/lib/glusterd2:z -v /var/log/glusterfs:/var/log/glusterfs:z -v /sys/fs/cgroup:/sys/fs/cgroup:ro -d --privileged=true --net=host -v /dev/:/dev <image_name:version> --config <new configuration file path>
```

Where:

        --net=host        ( Optional: This option brings maximum network throughput for your storage container)

        --privileged=true ( If you are exposing the `/dev/` tree of host to the container to create bricks from the container)

Bind mounting of following directories enables:

        `/var/lib/glusterd2`     : To make gluster metadata persistent in the host.
        `/var/log/glusterfs`    : To make gluster logs persistent in the host.
        `/etc/glusterfs`        : To make gluster configuration persistent in the host.

## check glusterd2 version

```
    #curl http://<container-ip>:24007/version
```

## check glusterd2 logs

```
    #docker logs <container-id>
```