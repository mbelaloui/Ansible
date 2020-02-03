# Ansible

Ansible is an automation agentless engine that enable us to describe an IT infrastructure throw playbook.   
Ansible push over ssh small programs, called 'Ansible modules' to nodes. This modules are used to describe the desired state of the system.
This modules are deleted when the pays is finished.

A good practice is to use ssh-keys instead of passwords, kerberos is also supported.
   
Use case :
* Provisioning the infra
* Config management
* App deployment
* Continuous delivery
* Security
* Orchestration

Setup ansible VM

- Run the setup_ansible_${OS}.sh
- Set up Hosts file <Inventories>
- Send ssh-key to the hosts
- Check if the SELinux in enabled on the remote nodes `getenforce` 
	* if it's enabled we have to install on the nodes the `libselinux-python` before using any cp/file/template related functions in Ansible.

## Inventories
 Is the list of the targets in which we want to automate 

 we can also setup, user and ssh-key location 

### example
```
---
[NAME_HOST]
ip/hosteName

[NAME_GROUP_HOST]
ip/hosteName
ip/hosteName

```
We can use dynamic inventory to pull the inventory form EC2, SpenStack, ...


## PlayBook
 YAML files that discribe the desired state of something.   

 PlayBooks contain plays.   
 Plays contain tasks.  
 Tasks are a list of actions that call modules.   
 Modules are the Actions that are been executed in the remote system.  

 Tasks run sequentially

 Handlers are triggered by tasks, and are run once at the end of plays


Strucutre for the PlayBook files

### example

```

---
- name:  NAME_OF_THE_PLAYBOOKS
  hosts: NAME_HOST/NAME_GROUP_HOST
  remote_user: USER_THAT_WILL_EXEC_ACTIONS_IN_REMOTE_HOST
  become_method: METHODE_TO_BECOME_USER
  become_user: USER_WITH_SUPER_PRIVILEGES
  var:
    - var1: VAR_TO_USE_IN_TASKS
    - var2:

  tasks:  ACTONS
  - name: NAME_TASKE
    module: IS USED TO TELL ANSIBLE HOW TO CONFIGURE THE TARGET SYSTEM

  handlers: 
  - name: NAME_HANDLERS
    service: ACTIONS TO DO WHEN ALL THE PLAYS OF THE PLAYBOOKS ARE SUCCESSFULLY COMPLETED

```

## RUN Ansible

 - Ad-Hoc : ansible <inventories> -m module --options
 - Playbooks : ansible-playbook --options playbooks.yml
 - Automation framework : Ansible Tower

## ANSIBLE GALAXY

 Is a repo which contain roles, playbooks and modules made the community.



##Modules :

```
 apt/yum
 command 
 copy
 file
 get_url
 git
 ping
 debug
 raw     : "very useful if the machine that we are talking to doesn't have python"
 script
 service
 shell
 synchronize
 template
 uri
 user
 wait_for
 assert
```




https://www.ansible.com/overview/how-ansible-works
