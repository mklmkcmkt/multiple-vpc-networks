Overview:
In this lab, you create several VPC networks and VM instances and test connectivity across networks. Specifically, you create two custom mode networks (managementnet and privatenet) with firewall rules and VM instances, as shown in this network diagram:

vm-appliance virtual machine connected to two vm instances, and management and privatenet networks

The mynetwork network, its firewall rules, and two VM instances (mynet-notus-vm and mynet-us-vm) have already been created for you in this Qwiklabs project.

Objectives
In this lab, you learn how to perform the following tasks:

Create custom mode VPC networks with firewall rules
Create VM instances using Compute Engine
Explore the connectivity for VM instances across VPC networks
Create a VM instance with multiple network interfaces
_______________________________________________________________________
Review:
In this lab, you created several custom mode VPC networks, firewall rules, and VM instances using the Cloud console and the gcloud command line. Then you tested the connectivity across VPC networks, which worked when pinging external IP addresses but not when pinging internal IP addresses. Thus you created a VM instance with three network interfaces and verified internal connectivity for VM instances that are on the subnets that are attached to the multiple interface VM.
