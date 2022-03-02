#!/bin/bash
# usage: install ansible
# verison: 2022-03-02 New

echo "This script install ansible via pip (online), tested at AlmaLinux 8.5."

echo " Installing python39..."
dnf -y install python39 &> /dev/null && echo "Python39 installed." || echo "Python39 installation failed."
echo

echo " Installing ansible(this may cause much time)..."
pip3 install ansible &> /dev/null && echo " ansible installed" || echo "ansible installation failed."
echo

echo " ansible version:"
ansible --version

