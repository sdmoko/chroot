## Add Group for chroot user
groupadd -g 9999 chrooters

## Set Username variable
username=test

## Create chroot jail
D=/home/jails
mkdir -p $D
mkdir -p $D/dev/
mknod -m 666 $D/dev/null c 1 3
mknod -m 666 $D/dev/tty c 5 0
mknod -m 666 $D/dev/zero c 1 5
mknod -m 666 $D/dev/random c 1 8

## Set Permissions
chown root:root $D
chmod 0755 $D

## Install Bash Shell in Chroot Jails
mkdir -p $D/bin
cp -v /bin/bash $D/bin
mkdir -p $D/lib/
mkdir -p $D/lib64/
mkdir -p $D/lib/x86_64-linux-gnu/
cp -v /lib/x86_64-linux-gnu/{libncurses.so.5,libtinfo.so.5,libdl.so.2,libc.so.6} $D/lib/
cp -v /lib64/ld-linux-x86-64.so.2 $D/lib64/
cp -va /lib/x86_64-linux-gnu/libnss_files* $D/lib/x86_64-linux-gnu/

## Add user to system
mkdir -p $D/etc/
adduser $username
cp -vf /etc/{passwd,group} $D
usermod -aG chrooters $username

## Configure SSHD
echo "##  Apply the chrooted jail to the group called chrooters ##" >> /etc/ssh/sshd_config
echo "Match Group chrooters" >> /etc/ssh/sshd_config
echo "ChrootDirectory /home/jails" >> /etc/ssh/sshd_config
echo "X11Forwarding no" >> /etc/ssh/sshd_config
echo "AllowTcpForwarding no" >> /etc/ssh/sshd_config
echo "AuthorizedKeysFile /home/jails/home/%u/.ssh/authorized_keys" >> /etc/ssh/sshd_config
systemctl restart ssh.service

## Install additional command
wget -O l2chroot http://www.cyberciti.biz/files/lighttpd/l2chroot.txt
chmod +x l2chroot
echo /webroot | sed -e 's/\/webroot/\/home\/jails/g' l2chroot
cp -v /bin/ls $D/bin/
cp -v /bin/date $D/bin/
/root/l2chroot /bin/ls
/root/l2chroot /bin/date
mkdir -p $D/home/$username
chown -R $username:$username $D/home/$username
chmod -R 0700 $D/home/$username
