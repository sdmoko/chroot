## Set Username Here
username=test

## Add and Config User
D=/home/jails
adduser $username
cp -vf /etc/{passwd,group} $D
usermod -aG chrooters $username
mkdir -p $D/home/$username
chown -R $username:$username $D/home/$username
chmod -R 0700 $D/home/$username
