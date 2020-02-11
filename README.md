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
- add public SSH-key to the authorized_key file on the remote nodes
- Confirm that we can ping all the nodes with the module [ping] ```ansible all -m ping```  
- Check if the SELinux in enabled on the remote nodes `getenforce` 
	* if it's enabled we have to install on the nodes the `libselinux-python` before using any cp/file/template related functions in Ansible.

## Inventories / Hostfile

Is the list of the targets/nodes in which we want to automate.   
The default location for the inventory file is /etc/ansible/hosts, we can specify different file at the run of the command line using -i <path>
We can organize our list of host be creating and nesting groups, that make scaling easy and let us take advantage of the full flexibility and repeatability of Ansible.
A good practice is to use dynamic inventory for more flexibility, and use the FQDN to define hosts rather than IPs.
We can store in the inventories aliases, variable for single with ```host vars``` or multiple hosts with ```group var```

### Example INI format 
```
---
[NAME_HOST]        # group names
ip/FQDNs           # Host_1

[NAME_GROUP_HOST]  # group names
ip/FQDNs           # Host_2
ip/FQDNs           # Host_3

```


https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html#intro-inventory


## Modules 

These Are the units of code that Ansible executes in the remote nodes.
Each modules as has a particular use.

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
https://docs.ansible.com/ansible/latest/modules/modules_by_category.html#modules-by-category


## Tasks

Is the units of actions in ansible.
Tasks are a list of actions that call modules.  

## PlayBook

The playbooks are ordered list of tasks, and are written in YAML format.   
PlayBooks contain plays   
Plays contain tasks  

Tasks run sequentially in a play

Strucutre for the PlayBook files

Every YAML file optionally starts with “---” and ends with “...”.

### Example

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
`...
```

https://docs.ansible.com/ansible/latest/user_guide/playbooks_intro.html#about-playbooks
## Handeler

Handler are special tasks that run at the end of a play if notified by another task.

if a configuration file gets changed, it will notify the service that is related too and do the actions given

## Variables


https://docs.ansible.com/ansible/latest/reference_appendices/playbooks_keywords.html

## Precedence rules

https://docs.ansible.com/ansible/latest/reference_appendices/general_precedence.html#general-precedence-rules

## RUN Ansible

 - Ad-Hoc : ansible <inventories> -m module --options   ```https://docs.ansible.com/ansible/latest/user_guide/
    ad-hoc commandes are not used for configration, management and deployment, these commands are of one time usage. 

 intro_adhoc.html#intro-adhoc```
 - Playbooks : ansible-playbook --options playbooks.yml
 - Automation framework : Ansible Tower


Ansible will run commands form current user account. If we want to change this behavior, w'll have to pass the username in the commands.

## ANSIBLE GALAXY

 Is a repo which contain roles, playbooks and modules made the community.





#### Stoped at 
https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html#id10
7. Ansible – Variables
mail mbelalou42@gmail.com






NB : see the diff [file / template] Tasks header
##  Configuring Ansible

https://docs.ansible.com/ansible/latest/installation_guide/intro_configuration.html#intro-configuration

https://opensource.com/downloads/ansible-quickstart?extIdCarryOver=true&sc_cid=701f2000001OH7YAAW

## Ressources
https://docs.ansible.com/ansible/latest/user_guide/become.html#become
https://docs.ansible.com/ansible/latest/user_guide/connection_details.html#connections
https://www.ansible.com/overview/how-ansible-works
https://vmmasterblog.wordpress.com/2017/02/22/introduction-to-ansible/






# Roles to write:


## Role 1 to all new machine  `init machine`
- With raw module install python in the target machines
- Send ssh-key.pub to the target machines
- Change the connection security to accept only keepass
- Restart ssh service

## Role 2 Config system to handle distributed services
- Call the role 1
- Swap 1%
- Ulimit <fd, Numbere of threads, lock memory>
- Increase the limit of the virtual memory. 

### `NB : the deb and rpm pachages of easticsearch will configure the virtual memory and Numbere of threads automaticly`


## Role 3 `Install default elasticsearch`
- Call the role 2
- Install elasticsearch.deb 
- configure Heap-Jvm

## Role 4 `install Master node elasticearch`
- Call the role 3
- Configure port `close 9200 Port`
- Copie the template file to the target machine


## Role 5 `install Data node elasticearch`
- Call the role 3
- Copie the template file to the target machine


## Role 6 `install Coordinating node elasticearch`
- Call the role 3
- Copie the template file to the target machine

## Role 6 `install Ingest node elasticearch`
- Call the role 3
- Copie the template file to the target machine
