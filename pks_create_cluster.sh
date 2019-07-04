#!/bin/bash

set -e # fail an print all command output

# sed -i 's/time.sleep(5)/time.sleep(0.5)/g' ./ansible-for-nsxt/library/* # Reduce mandatory sleep between commands

pks create-cluster k8s1 --external-hostname k8s1 --plan small
CLUSTER_ID=$(pks cluster k8s1 --json |jq -rc '.uuid')
echo "Created cluster with ID ${CLUSTER_ID}"
#CLUSTER_ID="e3fac4cd-cd54-45d3-8806-6ec828e3284d"

export ANSIBLE_LIBRARY="${PWD}/ansible-for-nsxt"
export ANSIBLE_MODULE_UTILS="${PWD}/ansible-for-nsxt/module_utils"

CLUSTER_RULES=$"cluster_firewall_rules_${CLUSTER_ID}.yml"
cp template_cluster_firewall_rules.yml ${CLUSTER_RULES}
sed -i "s/<cluster_id>/${CLUSTER_ID}/g" ${CLUSTER_RULES}

ansible-playbook nsgroup_firewall_section.yml --extra-vars="@${CLUSTER_RULES}" #-vvv
