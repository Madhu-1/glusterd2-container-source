#! /bin/bash

# Install required stuff
yum install -y  curl git make

# Setup Go
if ! yum install -y 'golang >= 1.6'
then
  GOURL=https://storage.googleapis.com/golang
  GOVERSION=1.9.5
  GOARCHIVE=go${GOVERSION}.linux-amd64.tar.gz
  mkdir /usr/local
  curl -o /tmp/${GOARCHIVE} -L ${GOURL}/${GOARCHIVE}
  tar -C /usr/local -xzf /tmp/${GOARCHIVE}
  rm -f /tmp/${GOARCHIVE}
fi

# Setup GOPATH
GOROOT=/usr/local/go
export PATH=$PATH:$GOROOT/bin




