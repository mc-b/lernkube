#!/bin/bash
#
#	Einstellungen

# VMs Prefix ohne "kube"
export VMS="xx1 xx2 xx3"
# Default GW
export VM_GATEWAY=192.168.178.1
# Fixe IP - Prefix
export VM_IPPREFIX=192.168.178
# Fixe IP - 1. IP Adresse
export FIP=211
# Memory pro VM
export VM_MEMORY=4096
# Interface fuer Bridge
# export VM_BRIDGE=', bridge: "enp0s25"'
export VM_BRIDGE=""