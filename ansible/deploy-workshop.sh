#!/bin/bash 
set -xe 

if [ "$#" -ne 2 ];
then 
  echo "Please pass source file"
  echo "USAGE to create deployment: $0 source_file create"
  echo "USAGE to delete deployment: $0 source_file remove"
  exit 1
elif [ ! -f deploy_scripts/$1 ];
then
  echo "SOURCE file not found  deploy_scripts/$1"
  exit 1 
fi

SOURCE_FILE=${1}
ACTION=${2}

source deploy_scripts/$SOURCE_FILE || exit $?
source deploy_scripts/functions.sh

echo $ACTION $WORKLOAD

# a TARGET_HOST is specified in the command line, without using an inventory file
ansible-playbook -i ${TARGET_HOST}, ./configs/ocp-workloads/${WORKLOAD_YAML} \
                 -e"ansible_ssh_private_key_file=~/.ssh/${SSH_PRIVATE_KEY}" \
                 -e"ansible_user=${SSH_USER}" \
                 -e"ansible_python_interpreter=python" \
                 -e"ocp_username=${OCP_USERNAME}" \
                 -e"ocp_workload=${WORKLOAD}" \
                 -e"guid=${GUID}" \
                 -e"ocp_user_needs_quota=true" \
                 -e"ocp_master=${MASTER_HOSTNAME}" \
                 -e"ocp_cluster_domain=${CLUSTER_DOMAIN}" \
                 -e"ocp_apps_domain=${APPS_DOMAIN}" \
                 -e"user_count=${NUM_USERS}" \
                 -e"user_password=${USER_PASSWORD}" \
                 -e"gogs_user_password=${GOGS_PASSWORD}" \
                 -e"quay_pull_user=${QUAY_PULL_USERNAME}" \
                 -e"quay_pull_password=${QUAY_PULL_PASSWORD}" \
                 -e"bastion_internal=${TARGET_HOST}" \
                 -e"subdomain_base_suffix=${DOMAIN}" \
                 -e"ACTION=${ACTION}"

if [ ${WORKLOAD} == "ocp4-workload-security-compliance-lab" ] && [ ${ACTION} == "create" ];
then 
  secuirty-compliance-lab
fi 