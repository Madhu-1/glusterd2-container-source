# remove Go
if ! yum remove -y golang
then
  rm -f /usr/local/go
fi
yum -y autoremove && yum -y clean all