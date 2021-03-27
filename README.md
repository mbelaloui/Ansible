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

inventory parameters: 
 - alias
 - ansible_host
 - ansible_connection <ssh / winrm / localhost >
 - ansible_port
 - ansible_user
 - ansible_ssh_pass / ansible_password

### Example INI format 
```
---
[NAME_HOST]        # group names
ip/FQDNs           # Host_1

[NAME_GROUP_HOST]  # group names [NAME_GROUP_HOST:children]  # group of groups
ip/FQDNs           # Host_2
ip/FQDNs           # Host_3

```

A good practice is to create the ``` group_vars ``` directory and add directories named after the groups or hosts, so all the groups will have the vriables defined in theses files available to them, this can be very useful to keep the variables organized this way when a single file gets too big, or when we want to use Vault on some group variables.

## Inventory Setup
### By envirenment
  we can group hosts by environment [test, stagn, prod, ...]   
  This make harder to accidentally change state of node inside the test environment when actualy wanted to update some staging servers

### BY function
  We can group hosts by functions[ DB, web, service_x,... ]   
This allows us to define some characteristics of a group of same service

### By location
  We can group hosts by theres locations[ location_1,location_2,... ]   
  This allows us to change state of hosts in a specific location.

NB : The goup_vas and the host_vars directories should be in the same directory of the inventory file to be taiken into account.

https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html#intro-inventory

## Patterns

  We use patterns any time we execute an ad-hoc command :    
    - ansible <pattern> -m <module_name> -a "<module_option>"   
  Or a playbook the pattern in the playbook is the content of the hosts:   
    - name: <play_name>   
      hosts: <pattern>

Since we often want to run a command or playbook against multiple host at once, patterns often refer to inventory groups.   

  ### Common patterns

| Description |	Pattern(s) |	Targets |
| ------------- |:-------------:| -----:|
| All hosts |	all (or *)| - |
|One host	| host1| - |
|Multiple hosts|  host1:host2 (or host1,host2)| - |
|One group |  webservers| - |
|Multiple groups |	webservers:dbservers  |	all hosts in webservers plus all hosts in dbservers|
|Excluding groups |	webservers:!atlanta |	all hosts in webservers except those in atlanta|
|Intersection of groups |	webservers:&staging | any hosts in webservers that are also in staging|


### Key words related to the host_file

- ansible_host   
    * The name of the host to connect to
- ansible_port   
    * The connection port number 'default 22'
- ansible_user  
    * The user name to use when connecting to the host
- ansible_password   
    * The password to use to authenticate to the host ``` Always use vault to store this variable ```
- ansible_ssh_private_key_file
    * To set the path of the private ssh key. ```Best Practice```





## Modules 

These Are the units of code that Ansible executes in the remote nodes.
Each modules as has a particular use.   
### modules should be idempotent and can relay when they have made a change on the remote system.   

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

The goal of a play is to map a group of hosts to some well defined roles, represented by things ansible calls tasks. At a basic level, a task is nothing more than a call to an ansible module.   

Tasks run sequentially in a play

Strucutre for the PlayBook files

Every YAML file optionally starts with “---” and ends with “...”.


### Example

https://github.com/ansible/ansible-examples

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

```
- name: template configuration file
  template:
    src: template.j2
    dest: /etc/foo.conf
  notify:
     - restart memcached
     - restart apache

handlers:
    - name: restart memcached
      service:
        name: memcached
        state: restarted
    - name: restart apache
      service:
        name: apache
        state: restarted
```   
When the config file is loaded to the target machine, the task will notify the tow handlers and the tow services will restart.

``` NB : we can't use variables in the name of the handler, this will case the entiere play to fail ```

Instead, w can use variables in the task parameters of the handler, and load the values using ``` include_vars ```

```
tasks:
  - name: Set host variables based on distribution
    include_vars: "{{ ansible_facts.distribution }}.yml"

handlers:
  - name: restart web service
    service:
      name: "{{ web_service_name | default('httpd') }}"
      state: restarted 
```   


Also handlers can listen to generic topic, and tasks can notify those topic 

```
handlers:  
    - name: restart memcached   
      service:   
        name: memcached   
        state: restarted   
      listen: "restart web services"   
    - name: restart apache   
      service:   
        name: apache   
        state: restarted   
      listen: "restart web services"    
tasks:  
    - name: restart everything   
      command: echo "this task will restart the web services"   
      notify: "restart web services"   
```  

* Notify handlers are always run in the same order they are defined, not in the order listed in the notify-statement. This is also the case for handlers using listen.   
* Handler names and listen topics live in a global namespace.   
* Handler names are templatable and listen topics are not.   
* Use unique handler names. If you trigger more than one handler with the same name, the first one(s) get overwritten. Only the last one defined will run.   
* You cannot notify a handler that is defined inside of an include. As of Ansible 2.1, this does work, however the include must be static.   


## Variables

Variables begin with a letter and never withe a special char.

Can be defined :
- In an inventory file
``` 
#for one host
[group]
host_name	variable_1= 42     variable_2=24
```	

``` 
#for miltiple host
[group]
host_name_1
host_name_2

[group:var]
variable_1=42
variable_2=24
```
- Inside a play book : vars
```
---
- name : test play
  hosts: group
  vars:
  	variable_1:42
```

- In a file outside the playbook using vars file in roles
- In the defaults dir containing files in roles
- set from the command line  ``` --extra-vars ``` or ``` -e ```

Once we've defined variables, we can use then in playbooks using Jinja2 templating.   

``` "{{ variable_1 }}" ```   

There is an othe type of variables. The Facts, facts are a way of getting data about remote systems for use in playbook variables.   
Facts are usually discovered automatically by the setup module, and if we know that we don't need facts data about ours hosts, and know everything about ours system, we can turn off fact gathering, this has advantages in scaling in push with very large numbers of systems.   


### registering variables
Variables are used for registering the result of an execution on a command, when we do that we crate a registered variable.   
```
  tasks:
     - shell: /usr/bin/foo
       register: foo_result
       ignore_errors: True

     - shell: /usr/bin/bar
       when: foo_result.rc == 5
```


Here is the order of precedence from least to greatest (the last listed variables winning prioritization):

- command line values (eg “-u user”)   
- role defaults [1]   
- inventory file or script group vars [2]   
- inventory group_vars/all [3]   
- playbook group_vars/all [3]   
- inventory group_vars/* [3]   
- playbook group_vars/* [3]   
- inventory file or script host vars [2]   
- inventory host_vars/* [3]   
- playbook host_vars/* [3]   
- host facts / cached set_facts [4]   
- play vars   
- play vars_prompt   
- play vars_files   
- role vars (defined in role/vars/main.yml)   
- block vars (only for tasks in block)   
- task vars (only for the task)   
- include_vars   
- set_facts / registered vars   
- role (and include_role) params   
- include params   
- extra vars (always win precedence)   


### Scoping variables
You can decide where to set a variable based on the scope you want that value to have. Ansible has three main scopes:

- Global: this is set by config, environment variables and the command line   
- Play: each play and contained structures, vars entries (vars; vars_files; vars_prompt), role defaults and vars.   
- Host: variables directly associated to a host, like inventory, include_vars, facts or registered task outputs   



https://docs.ansible.com/ansible/latest/reference_appendices/playbooks_keywords.html

## Precedence rules

Variables defined in inventory [Hosts, host_vas, group_vars] could be overriden by the playbook's [vars, var_file], and 
variable in playbook could be overriden by the command line -extra-vars "key=val"

https://docs.ansible.com/ansible/latest/reference_appendices/general_precedence.html#general-precedence-rules

## conditionals

we use the ```when``` key word to expresse condition in a play book eg:

  we whant to install nginx in a debian and a redhat system   
  here w'll use the ```ansible_os_family``` wich is a built-in variable that store the name of the os   
  in this case, we will use the apt for a debian family os and the yum package manager for the redhat
  we can have a play that 
   
```
  -
    name: "install nginx"
    hosts: my_hosts
    tasks:
      -
        name: "install inginx in Debian"
        apt:
          name: nginx
          state: present
        when: "ansible_os_family == debian"

      -
        name: "install inginx in Redhat"
        yum:
          name: nginx
          state: present
        when: "ansible_os_family == redhat"
```

we can also use the conditional in a loop 

we want to install wget, git and not apache

```
---

-
 name: "Install multiple packages with conditionals playbook"
 hosts: debian
 vars:
   packages:
   - 
     name: git
     required: True
   - 
     name: wget
     required: True
   - 
     name: apache
     required: Flase
 tasks:
 - 
   name: "install {{ item.name }} packages in Debian"
   apt:
    name: "{{ item.name }}"
    state: present
   when: item.required == True
   loop: "{{packages}}"  in the past we use the `with_items:` keyword 
...
```

NB : never use the jinja2 syntax in the when commande

we have a lot of with_*    [*] are plugins like 

with_file, with_ini, ....

inventory file 

```
cat hosts                            
debian ansible_host=10.12.1.112 ansible_user=user ansible_connection=ssh
```

NB : Can be run with ```ansible-playbook -i hosts install.yml ```

## RUN Ansible

### Ad-Hoc commands
  The ad-hoc commands are quick and easy, that demonstarte the simplicity and the power of Ansible, but are not re-usable.
  We can use any Ansible module in ad-hoc task.

 * Ad-Hoc : ansible <inventories> -m module --options   ```https://docs.ansible.com/ansible/latest/user_guide/ ```   
    ad-hoc commandes are not used for configration, management and deployment, these commands are of one time usage. 

  #### Use caes 

  * reboot servers ``` ansible <pattern> -a "/sbin/reboot" -f 10 -u username --become --ask-become-pass ```
  * copy files ``` ansible <pattern> -m copy -a "src=/etc/hosts dest=/tmp/hosts" ```
  * manage packages ```  ansible <pattern> -m yum -a "name=acme state=latest" ```
  * manage users/groups ``` ansible all -m user -a "name=foo password=<crypted password here>" ```
  * manage services ``` ansible <pattern> -m service -a "name=httpd state=restarted" ```
  * Gethering facts ``` ansible all -m setup ```

 

 intro_adhoc.html#intro-adhoc```
 * Playbooks : ansible-playbook --options playbooks.yml
 * Automation framework : Ansible Tower


Ansible will run commands form current user account. If we want to change this behavior, w'll have to pass the username in the commands.

## ANSIBLE GALAXY

 Is a repo which contain roles, playbooks and modules made the community.



#### Stoped at 
https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse.html




NB : see the diff [file / template] Tasks header
##  Configuring Ansible

https://docs.ansible.com/ansible/latest/installation_guide/intro_configuration.html#intro-configuration

https://opensource.com/downloads/ansible-quickstart?extIdCarryOver=true&sc_cid=701f2000001OH7YAAW

## Ressources
https://docs.ansible.com/ansible/latest/user_guide/become.html#become
https://docs.ansible.com/ansible/latest/user_guide/connection_details.html#connections
https://www.ansible.com/overview/how-ansible-works
https://vmmasterblog.wordpress.com/2017/02/22/introduction-to-ansible/



Plays_dire:
|-> main.yml
|-> Inventory:            execution_order
    |->inventory_1.yml      1
    |->inventory_2.yml      2
    |-> group_vas:
      |-> group_1.yml       3
      |-> host_1.yml        4


NB : The inventories are merged in alphabetical order according to the filenames so the result can be controlled by adding prefixes to the files.
If a variable is defined in the inventor_1.yml and in the inventory_2.yml and group_1.yml and host_1.yml. It's the value in the host_1.yml that will be taken account.