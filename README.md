# Ansible

Ansible is an automation agentless engine that enable us to describe an IT infrastructure throw playbook.   
   
   
Use case :
* We can deploy app
* Provisioning
* Config maagement
* Continuous delivry
* Securit and Compliance
* Orchestration

Setup ansible VM

- Run the setup_ansible_${OS}.sh
- Set up Hosts file <Inventories>
- Send ssh-key to the hosts
- Check if the SELinux in enabled on the remote nodes `getenforce` 
	* if it's enabled we have to install on the nodes the `libselinux-python` before using any cp/file/template related functions in Ansible.

## Inventories
 Is the list of the targets in witch we whant to automate

## PlayBook
 YAML files that discribe the desired state of something.

Strucutre for the PlayBook files


'''
---
- name:
 hosts:
'''










