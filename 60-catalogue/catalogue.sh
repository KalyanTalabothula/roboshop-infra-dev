#!/bin/bash

component=$1
dnf install ansible -y
ansible-pull -U https://github.com/KalyanTalabothula/ansible-roboshop-roles.git -e component=$1 main.yaml

# miru yekkada nimdi pull chestunnaru ani -U (URL ani ardham) ani evvamdi inka mottam ansible chusukuntumdhii. 
