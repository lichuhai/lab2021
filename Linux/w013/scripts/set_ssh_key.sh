#!/bin/bash
# usage: copy ssh key to remote hosts, generate if necessary
# version: 2022-03-02 new

rpm -q sshpass &> /dev/null || { dnf -y install epel-release && dnf -y install sshpass; }

[ -f /root/.ssh/id_rsa ] || ssh-keygen -f /root/.ssh/id_rsa -P ''

[ -f hosts ] || { echo "you need to create a hosts file containing a list of ip first"; exit 1; }

read -s -p "Input the remote vm's password: " INPUT
export SSHPASS=$INPUT
echo $SSHPASS
while read ip; do
  sshpass -e ssh-copy-id -f -o StrictHostKeyChecking=no $ip
done < hosts

