#!/bin/bash

set -e

CLUSTER_NAME="$1"
if [ -z "$CLUSTER_NAME" ] 
then
	echo "Please pass in a cluster name"
  exit 1
fi

pks create-cluster ${CLUSTER_NAME} --external-hostname ${CLUSTER_NAME} --plan small
CLUSTER_ID=$(pks cluster ${CLUSTER_NAME} --json |jq -rc '.uuid')
echo "Created cluster with ID ${CLUSTER_ID}"

export ANSIBLE_LIBRARY="${PWD}/ansible-for-nsxt"
export ANSIBLE_MODULE_UTILS="${PWD}/ansible-for-nsxt/module_utils"

CLUSTER_RULES_FILE=$"cluster_firewall_rules_${CLUSTER_ID}.yml"
cp template_cluster_firewall_rules.yml ${CLUSTER_RULES_FILE}
sed -i "s/<cluster_id>/${CLUSTER_ID}/g" ${CLUSTER_RULES_FILE}

ansible-playbook nsgroup_firewall_section.yml --extra-vars="@${CLUSTER_RULES_FILE}" #-vvv