# CentOS-8
Bash Script

1. docker pull centos:8

2. docker run -it --name script centos:8

3. once you access the centos 8 using docker container, we need to adjust repository for the /etc/yum.repos.d/ for the following:
  * CentOS-Linux-AppStream.repo
    [appstream]
    name=CentOS-$releasever - AppStream
    baseurl=http://vault.centos.org/8.5.2111/AppStream/x86_64/os/
    enabled=1
    gpgcheck=1
    gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centos8

  * CentOS-Linux-BaseOS.repo
    [baseos]
    name=CentOS-$releasever - Base
    baseurl=http://vault.centos.org/8.5.2111/BaseOS/x86_64/os/
    enabled=1
    gpgcheck=1
    gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centos8

  * CentOS-Linux-Extras.repo
    [extras]
    name=CentOS-$releasever - Extras
    baseurl=http://vault.centos.org/8.5.2111/extras/x86_64/os/
    enabled=1
    gpgcheck=1
    gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centos8

4. yum update -y
5. 
