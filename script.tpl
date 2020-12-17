#!/bin/bash
# Install AWS EFS Utilities
sudo yum update -y
sudo yum install -y amazon-efs-utils docker
sudo systemctl start docker
# Mount EFS
sudo mkdir /opt/minecraft
efs_id="${efs_id}"
sudo mount -t efs $efs_id:/ /opt/minecraft
# Edit fstab so EFS automatically loads on reboot
sudo echo $efs_id:/ /efs /opt/minecraft defaults,_netdev 0 0 >> /etc/fstab
sudo chown 845:845 /opt/minecraft
#run minecraft
sudo docker run -d -p 25565:25565 --name mc -v /var/minecraft:/opt/minecraft -e MEMORY=2G -e EULA=TRUE itzg/minecraft-server