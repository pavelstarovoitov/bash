#!/bin/bash
set -e
#Check that current user is root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

 #1. (as root) Create user Name_Surname with primary group Name_Surname, UID = 505, GID=505
 echo "#1."
user_name=Pavel_Staravoitau1
group_name=Pavel_Staravoitau1
uid=505
gid=505
if id -u $uid >/dev/null 2>&1; then # Check that user exist or not
  echo "user  ${user_name} exists"
else
  echo "user does not exist"
  echo "creating user..."
  groupadd -g $gid $group_name && adduser  -u $uid -g $gid $user_name 
  echo "user  ${user_name} created"
fi

#2.(as root) Create user mongo with primary group staff, UID=600, GID=600
echo "#2."
user_name=mongo
group_name=staff
uid=600
gid=600
if id -u $uid >/dev/null 2>&1; then
  echo "user  ${user_name} exists" 
  
else
  echo "user does not exist"
  echo "creating user..."
  groupadd -g $gid $group_name && adduser  -u $uid -g $gid $user_name \
  && echo "user  ${user_name} created"
fi

#3. (as root) Create folders /apps/mongo/, give 750 permissions, set owner mongo:staff
echo "#3."
user_name=mongo
group_name=staff
folder_name="/apps/mongo/"
if [ ! -d $folder_name ]; then 
  echo "NOT EXIST"
  echo "creating folder"
  mkdir -p $folder_name && chmod 750 $folder_name \
  && chown $user_name:$group_name $folder_name
  echo "folder $folder_name created"
  ls -ll /apps
else 
  echo " $folder_name exist"
  ls -ll /apps/
fi 

#4.(as root) Create folders /apps/mongodb/, give 750 permissions, set owner mongo:staff
echo "#4."
user_name=mongo
group_name=staff
folder_name="/apps/mongodb/"
if [ ! -d $folder_name ]; then 
  echo "NOT EXIST"
  echo "creating folder"
  mkdir -p $folder_name && chmod 750 $folder_name \
  && chown $user_name:$group_name $folder_name
  echo "folder $folder_name created"
  ls -ll /apps/
else 
  echo " $folder_name exist"
  ls -ll /apps/
fi 

# 5.(as root) Create folders /logs/mongo/, give 740 permissions, set owner mongo:staff
echo "#5."
user_name=mongo
group_name=staff
folder_name="/logs/mongo/"
if [ ! -d $folder_name ]; then 
  echo "NOT EXIST"
  echo "creating folder"
  mkdir -p $folder_name && chmod 740 $folder_name \
  && chown $user_name:$group_name $folder_name
  echo "folder $folder_name created"
  ls -ll /logs/
else 
  echo "$folder_name exist"
  ls -ll /logs/
fi

# 6.(as mongo) Download with wget https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-3.6.5.tgz
echo "#6."
user_name=mongo
uid=600
if  which wget >/dev/null 2>&1; then
  echo "wget installed" 
else
  echo "wget NOT installed" && echo "installing wget ..."
  sudo yum install wget -y 
fi


if   id -u $uid >/dev/null 2>&1; then
    home_mongo=$(getent passwd mongo | cut -d: -f6)
    if [ -f "$home_mongo/mongodb-linux-x86_64-3.6.5.tgz" ] ||[ -f "./mongodb-linux-x86_64-3.6.5.tgz" ]; then
        echo " mongodb-linux-x86_64-3.6.5.tgz exits"
    else
        echo "not exits"  
        runuser -l  $user_name -c 'wget https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-3.6.5.tgz -P ./'
        mv $home_mongo/mongodb-linux-x86_64-3.6.5.tgz ./
    fi
    
else
  echo "user does not exist"
fi

# 7.(as mongo) Download with curl https://fastdl.mongodb.org/src/mongodb-src-r3.6.5.tar.gz
echo "#7."
user_name=mongo
uid=600
if  which wget >/dev/null 2>&1; then
  echo "curl installed" 
else
  echo "curl NOT installed" && echo "installing curl ..."
  sudo yum install curl -y 
fi


if  id -u $uid >/dev/null 2>&1; then
    home_mongo=$(getent passwd mongo | cut -d: -f6)

    if [ -f "$home_mongo/mongodb-src-r3.6.5.tar.gz" ] || [ -f "./mongodb-src-r3.6.5.tar.gz"  ]; then
        echo " mongodb-src-r3.6.5.tar.gz exits"
    else
        echo "not exits"  
        runuser -l  $user_name -c 'curl -o mongodb-src-r3.6.5.tar.gz https://fastdl.mongodb.org/src/mongodb-src-r3.6.5.tar.gz'
        mv $home_mongo/mongodb-src-r3.6.5.tar.gz ./
    fi
    
else
  echo "user does not exist"
fi
# 8.(as mongo) Unpack mongodb-linux-x86_64-3.6.5.tgz to /tmp/
echo "#8."
user_name=mongo
uid=600
 if [ -f "./mongodb-linux-x86_64-3.6.5.tgz"  ]; then
    echo " mongodb-linux-x86_64-3.6.5.tgz exits"

    if [ ! -d "/tmp/mongodb-linux-x86_64-3.6.5"  ] && [ ! -d "/tmp/mongo" ]; then
        dir=$(pwd)
        path="$dir/mongodb-linux-x86_64-3.6.5.tgz"
        echo $dir
        chmod 755 $dir
        chmod 755 $path
        ls -ll $path
        runuser -l  $user_name -c "tar -xvf $path -C /tmp/"
    else
        echo "already extracted"  
    fi  

else
    echo "not exits"  

fi

# 9.(as mongo) Copy ./mongodb-linux-x86_64-3.6.5/* to /apps/mongo/
echo "#9."
if [ -d "/tmp/mongodb-linux-x86_64-3.6.5"  ]; then
        echo " /tmp/mongodb-linux-x86_64-3.6.5 exits"
        if [ -d "/tmp/mongo"  ]; then
            rm -rf /tmp/mongo
        else
            echo ""
        fi
        runuser -l  $user_name -c 'mv  /tmp/mongodb-linux-x86_64-3.6.5/ /tmp/mongo'
        runuser -l  $user_name -c 'cp -r /tmp/mongo/ /apps/'
    else
        echo "not exits"  
fi

# 10.(as mongo) Update PATH on runtime by setting it to PATH=<mongodb-install-directory>/bin:$PATH
echo "#10."
user_name=mongo
runuser -l  $user_name -c "PATH=/apps/mongo:$PATH"
#sudo -u mongo PATH=/apps/mongo/bin:$PATH  
su -c "echo $PATH"  mongo

# 11.(as mongo) Update PATH in .bash_profile and .bashrc with the same
echo "#11."
chmod 660 /home/mongo/.bashrc
if cat /home/mongo/.bashrc | grep "/apps/mongo/bin" >/dev/null 2>&1; then
    echo "already added"
    cat /home/mongo/.bashrc | grep "/apps/mongo/bin"
else
    su -c "echo export PATH=/apps/mongo/bin:$PATH >> /home/mongo/.bashrc" $user_name
fi

if cat /home/mongo/.bash_profile | grep "/apps/mongo/bin" >/dev/null 2>&1; then
    echo "already added"
    cat /home/mongo/.bash_profile | grep "/apps/mongo/bin"
else
    su -c "echo export PATH=/apps/mongo/bin:$PATH >> /home/mongo/.bash_profile" $user_name
fi

# 12.(as root) Setup number of allowed processes for mongo user: soft and hard = 32000
echo "#12."
if cat /etc/security/limits.conf| grep "mongo hard nproc 32000" >/dev/null 2>&1; then
    echo "already added"
    source /home/mongo/.bash_profile
else
    su -c "echo 'ulimit -u 32000' >> /home/mongo/.bash_profile" $user_name
    echo "mongo hard nproc 32000" >> /etc/security/limits.conf
    echo "mongo soft nproc 32000" >> /etc/security/limits.conf
    
    source /home/mongo/.bash_profile
fi

ulimit -a mongo | grep "max user processes"

# 13.(as root) Give sudo rights for Name_Surname to run only mongod as mongo user
echo "#13."
usermod -aG wheel mongo >/dev/null 2>&1
usermod -aG wheel Pavel_Staravoitau1 >/dev/null 2>&1

if  [ -f "/etc/sudoers.d/Pavel_Staravoitau1" ]; then
    echo " 13 already added"
    tail -5 /etc/sudoers
else
    echo "Pavel_Staravoitau1    ALL =(mongo) NOPASSWD: /apps/mongo/bin/mongod" > /etc/sudoers.d/Pavel_Staravoitau1
fi


# 14.(as root) Create mongo.conf from sample config file from archive 7.
echo "#14."
if [ ! -d "/tmp/mongodb-src-r3.6.5"  ] || [ ! -f "/etc/mongod.conf" ]; then
  tar -xzf ./mongodb-src-r3.6.5.tar.gz -C /tmp/
  cp /tmp/mongodb-src-r3.6.5/rpm/mongod.conf /etc/mongod.conf
else 
  echo " /etc/mongod.conf all on place"
fi

# 15.(as root) Replace systemLog.path and storage.dbPath with /logs/mongo/ and /apps/mongodb/ accordingly in mongo.conf using sed or AWK
echo "#15."
sed -i.bak 's@/var/log/mongodb/mongod.log@/logs/mongo/mongod.log@' /etc/mongod.conf
sed -i 's@/var/lib/mongo@/apps/mongodb/@' /etc/mongod.conf

cat /etc/mongod.conf | grep "/logs/mongo"
cat /etc/mongod.conf | grep "/apps/mongodb"


# 16.(as root) Create SystemD unit file called mongo.service. Unit file requirenments:
# a.Pre-Start: Check if file /apps/mongo/bin/mongod and folders (/apps/mongodb/ and /logs/mongo/) exist, check if permissions and ownership are set correctly.
echo "#16."
/usr/bin/mkdir -p /var/run/mongodb
/usr/bin/chown mongo:staff /var/run/mongodb

cat > /etc/systemd/system/mongo.service << 'EOF'
[Unit]
Description=MongoDB Database Server
After=network.target
ConditionPathIsDirectory=/apps/mongodb/
ConditionPathIsDirectory=/logs/mongo/
ConditionPathExists=/apps/mongo/bin/mongod

[Service]
User=mongo
Group=staff
Environment="OPTIONS=-f /etc/mongod.conf"
ExecStart=/apps/mongo/bin/mongod $OPTIONS

ExecStartPre=/usr/bin/mkdir -p /var/run/mongodb
ExecStartPre=/usr/bin/chmod 0755 /var/run/mongodb
ExecStartPre=/usr/bin/chown mongo:staff /var/run/mongodb
PIDFile=/var/run/mongodb/mongod.pid

ExecStartPre=/usr/bin/chown mongo:staff /apps/mongodb/
ExecStartPre=/usr/bin/chown mongo:staff /logs/mongo/
ExecStartPre=/usr/bin/chown mongo:staff /apps/mongo/bin/mongod
ExecStartPre=/usr/bin/chmod 755 /apps/mongo/bin/mongod
ExecStartPre=/usr/bin/chmod 750 /apps/mongodb/
ExecStartPre=/usr/bin/chmod 740 /logs/mongo/

[Install]
WantedBy=default.target 
EOF
head -5 /etc/systemd/system/mongo.service


# 17.(as root) Add mongo.service to autostart
echo "#17."
# if which lsof > /dev/null 2>&1; then
#    systemctl start mongo
#    if lsof -i | grep "mongod" > /dev/null 2>&1; then   
#        if [ ! -h "/etc/systemd/system/default.target.wants/mongo.service" ];then
#          systemctl enable mongo
#       fi
#     fi
# else 
#     yum install lsof -y > /dev/null 2>&1
#     systemctl start mongo
#     if lsof -i | grep "mongod" > /dev/null 2>&1; then   
#       echo "enable "
#       if [ ! -h "/etc/systemd/system/default.target.wants/mongo.service" ];then
#          systemctl enable mongo
#       fi
#     fi
# fi
systemctl start mongo
systemctl enable mongo 

if [ -h "/etc/systemd/system/default.target.wants/mongo.service" ];then
  echo "created /etc/systemd/system/default.target.wants/mongo.service"
fi
