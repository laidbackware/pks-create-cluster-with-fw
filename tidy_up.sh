#!/bin/bash

set -e

CLUSTER_NAME="$1"
if [ -z "$CLUSTER_NAME" ] 
then
	echo "Please pass in a cluster name"
  exit 1
fi

CLUSTER_ID=$(pks cluster ${CLUSTER_NAME} --json |jq -rc '.uuid')

pks delete-cluster ${CLUSTER_NAME} --non-interactive

cluster_state="in progress"

while [[ "$cluster_state" == "in progress" ]]; do
  cluster_state=$(pks cluster "$CLUSTER_NAME" --json | jq -rc '.last_action_state')
  echo "${cluster_state}..."
  sleep 10
done

echo "Deleted cluster with ID ${CLUSTER_ID}"

CLUSTER_RULES_FILE=$"cluster_firewall_rules_${CLUSTER_ID}.yml"
sed -i "s/state: present/state: absent/g" ${CLUSTER_RULES_FILE}

export ANSIBLE_LIBRARY="${PWD}/ansible-for-nsxt"
export ANSIBLE_MODULE_UTILS="${PWD}/ansible-for-nsxt/module_utils"
ansible-playbook nsgroup_firewall_delete.yml --extra-vars="@${CLUSTER_RULES_FILE}" #-vvv

rm ${CLUSTER_RULES_FILE}