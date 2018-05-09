FROM centos:7

MAINTAINER Humble Chirammal hchiramm@redhat.com Madhu Rajanna mrajanna@redhat.com

ENV container docker
ADD ./golang/setup.sh /setup.sh
ADD ./golang/teardown.sh /teardown.sh
# let's setup all the necessary environment variables
ENV BUILD_HOME=/build
ENV GOPATH=$BUILD_HOME/golang
ENV GOBIN=$BUILD_HOME/golang/bin
ENV PATH=$GOPATH/bin:$PATH
#glusterd2 branch
ENV GD2_BRANCH="master"

LABEL architecture="x86_64" \
      name="gluster/gluster-centos" \
      version="4.0" \
      vendor="CentOS Community" \
      summary="This image has a running glusterfs service ( CentOS 7 + Gluster 4.0)" \
      io.k8s.display-name="Gluster 4.0 based on CentOS 7" \
      io.k8s.description="Gluster Image is based on CentOS Image which is a scalable network filesystem. Using common off-the-shelf hardware, you can create large, distributed storage solutions for media streaming, data analysis, and other data- and bandwidth-intensive tasks." \
      description="Gluster Image is based on CentOS Image which is a scalable network filesystem. Using common off-the-shelf hardware, you can create large, distributed storage solutions for media streaming, data analysis, and other data- and bandwidth-intensive tasks." \
      io.openshift.tags="gluster,glusterfs,glusterfs-centos"

RUN yum --setopt=tsflags=nodocs -y update && yum install -y centos-release-gluster40 && yum clean all && \
      (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done) && \
      rm -f /lib/systemd/system/multi-user.target.wants/* &&\
      rm -f /etc/systemd/system/*.wants/* &&\
      rm -f /lib/systemd/system/local-fs.target.wants/* && \
      rm -f /lib/systemd/system/sockets.target.wants/*udev* && \
      rm -f /lib/systemd/system/sockets.target.wants/*initctl* && \
      rm -f /lib/systemd/system/basic.target.wants/* &&\
      rm -f /lib/systemd/system/anaconda.target.wants/* &&\
      yum --setopt=tsflags=nodocs -y install nfs-utils attr iputils iproute openssh-server openssh-clients ntp rsync tar cronie sudo xfsprogs glusterfs glusterfs-server glusterfs-rdma glusterfs-geo-replication && yum clean all && \
      sed -i '/Defaults    requiretty/c\#Defaults    requiretty' /etc/sudoers && \
      sed -i '/Port 22/c\Port 2222' /etc/ssh/sshd_config && \
      sed -i 's/Requires\=rpcbind\.service//g' /usr/lib/systemd/system/glusterd.service && \
      sed -i 's/rpcbind\.service/gluster-setup\.service/g' /usr/lib/systemd/system/glusterd.service && \
      sed -i 's/ENV{DM_UDEV_DISABLE_OTHER_RULES_FLAG}=="1", ENV{SYSTEMD_READY}="0"/ENV{DM_UDEV_DISABLE_OTHER_RULES_FLAG}=="1", GOTO="systemd_end"/g' /usr/lib/udev/rules.d/99-systemd.rules && \
      mkdir -p /etc/glusterfs_bkp /var/lib/glusterd_bkp /var/log/glusterfs_bkp &&\
      cp -r /etc/glusterfs/* /etc/glusterfs_bkp &&\
      cp -r /var/lib/glusterd/* /var/lib/glusterd_bkp &&\
      cp -r /var/log/glusterfs/* /var/log/glusterfs_bkp && \
      sed -i.save -e "s#udev_sync = 1#udev_sync = 0#" -e "s#udev_rules = 1#udev_rules = 0#" -e "s#use_lvmetad = 1#use_lvmetad = 0#" /etc/lvm/lvm.conf

#glusterd2
RUN chmod +x /setup.sh && /setup.sh &&\
      mkdir $BUILD_HOME $GOPATH $GOBIN && \
      mkdir -p  /etc/glusterd2 $GOPATH/src/github.com/gluster && \
      cd $GOPATH/src/github.com/gluster && \
      git clone -b $GD2_BRANCH https://github.com/gluster/glusterd2.git && \
      cd $GOPATH/src/github.com/gluster/glusterd2 && \
      ./scripts/install-reqs.sh && make  && \
      cp build/glusterd2 /usr/bin/glusterd2 && \
      cp build/glustercli /usr/bin/glustercli &&\
      cp glusterd2.toml.example /etc/glusterd2/glusterd2.toml &&\
      chmod +x /teardown.sh && /teardown.sh &&\
      cd && rm -rf $BUILD_HOME
ADD ./glusterd2.service /etc/systemd/system/glusterd2.service   

VOLUME [ "/sys/fs/cgroup" ]
ADD gluster-setup.service /etc/systemd/system/gluster-setup.service
ADD gluster-setup.sh /usr/sbin/gluster-setup.sh

RUN chmod 644 /etc/systemd/system/glusterd2.service /etc/systemd/system/gluster-setup.service && \
      chmod 500 /usr/sbin/gluster-setup.sh && \
      systemctl disable nfs-server.service && \
      systemctl mask getty.target && \
      systemctl enable ntpd.service && \
      systemctl enable gluster-setup.service &&\
      systemctl enable glusterd2.service


EXPOSE 2222 111 245 443 24007 24008 2379 2389 2049 8080 6010 6011 6012 38465 38466 38468 38469 49152 49153 49154 49156 49157 49158 49159 49160 49161 49162

CMD ["/usr/sbin/init"]
