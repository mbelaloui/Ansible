#!/bin/bash

## 
readonly NORMAL_EXIT_ID=0
readonly ANSWER_POSITIVE=1
readonly ANSWER_NEGATIVE=2

## Messages
readonly ACTION_OK="\033[0;32mPassed\033[0m"
readonly ACTION_KO="\033[0;31mFailed\033[0m"

## Wait Variables
readonly WAIT_MSG_DEFAULT="."
readonly WAIT_MSG_MAX_REP_DEFAULT=3
readonly WAIT_MSG_TIMEOUT_DEFAULT=0.5

## Events Messages
readonly INSTALL_ANSIBLE_MSG="Insatll Ansible"
readonly INSTALL_SSHPASS_MSG="Insatll sshpass"
readonly INVENTORY_FILE_NOT_FOUND_MSG="Inventory file not found..."

## ACTION NAME
readonly GET_LIST_TARGET_HOST_ACTION="input inventory file"

## Events ID
readonly START_SCRIPT_ID=101
readonly ANSIBLE_IS_INSTALLED_ID=102
readonly ANSIBLE_IS_NOT_INSTALLED_ID=103
readonly SSHPASS_IS_NOT_INSTALLED_ID=104
readonly SSHPASS_IS_INSTALLED_ID=105
readonly INVENTORY_FILE_NOT_FOUND_ID=106

# "${INVENTORY_FILE_NOT_FOUND_ID}" "${GET_LIST_TARGET_HOST_MSG}"

## Error ID
readonly SUDO_PRIVILEGE_NEEDED_ERROR=100

## INVENTORY FILE
INVENTORY_FILE_FORMAT_DEFAULT=".yml"
INVENTORY_FILE_NAME_DEFAULT="${PWD}/inventory${INVENTORY_FILE_FORMAT_DEFAULT}"

## In Run Variable
EXE_MANE=
# RSA_KEY_PATH
# RSA_KEY_NAME

log()
{
  EVENT_STATUT=$1
  EVENT=$2
  EVENT_ID=$3

  echo
  echo -e "Task: ${EVENT} : [${EVENT_STATUT}]"
  echo

  if [[ ${EVENT_ID} -eq ${SUDO_PRIVILEGE_NEEDED_ERROR} ]]
  then
    echo "     Sudo Privileges Needed..."
    usage
  fi
}

usage()
{
  echo
  echo "     -------------------------------------"
  echo "         Usage :"
  echo "               sudo ${EXE_MANE}"
  echo "     -------------------------------------"
  echo
}

wait_msg()
{
  if [ -z $1 ]
  then
    WAIT_MSG_MAX_REP=${WAIT_MSG_MAX_REP_DEFAULT}
  else
    WAIT_MSG_MAX_REP=$1
  fi
  if [ -z $2 ]
  then
    WAIT_MSG_TIMEOUT=${WAIT_MSG_TIMEOUT_DEFAULT}
  else
    WAIT_MSG_TIMEOUT=$2
  fi
  if [ -z $3 ]
  then
    WAIT_MSG=${WAIT_MSG_DEFAULT}
  else
    WAIT_MSG=$3      
  fi
  echo -n "Loading "
  for i in $(seq 1 ${WAIT_MSG_MAX_REP}); do
    echo -n "${WAIT_MSG}"
    sleep ${WAIT_MSG_TIMEOUT}
  done
}

setup_ansible()
{
  echo
  echo "     ---------------------------------------"
  echo "               Start Ansible Setup"
  echo "     ---------------------------------------"
  echo
  echo "Starting ansible setup ... Please wait ... "
  apt-get install ansible -y > /dev/null 2>&1
  RET_INSTALL=$?
  if [ "${RET_INSTALL}" -eq "${NORMAL_EXIT_ID}" ]
  then
    log "${ACTION_OK}" "${INSTALL_ANSIBLE_MSG}"
    ansible --version
  else
    if [ "${RET_INSTALL}" -eq "${SUDO_PRIVILEGE_NEEDED_ERROR}" ]
    then
      log "${ACTION_KO}" "${INSTALL_ANSIBLE_MSG}" "${SUDO_PRIVILEGE_NEEDED_ERROR}"
      return "${SUDO_PRIVILEGE_NEEDED_ERROR}"
    else
      log "${ACTION_KO}" "${INSTALL_ANSIBLE_MSG}" 
      return "${ANSIBLE_IS_NOT_INSTALLED_ID}"
    fi
  fi
  return "${ANSIBLE_IS_INSTALLED_ID}"
}

ask_choice()
{
  echo
  echo "     Please enter your response :"
  echo
  echo "         y              : To configure ssh connexion to your target"
  echo
  echo "         Or something else to continue without configuring ssh connection to targets machines"
  echo
  echo -n " please type your answer > "
  read CHOICE
  echo
  if [ "${CHOICE}" == "y" ]
  then
    return ${ANSWER_POSITIVE}
  else
    return ${ANSWER_NEGATIVE}
  fi
}

# check_invenroty_file()
# {
#     FILE=$1
#     TARGET_LIST=$(cat inventory.yml | awk -F " " '{ print $2}' | awk -F "ansible_host=" '{ print $2}'| sort -u)

#     for t in ${TARGET_LIST}
#     do 
#         result=$(ping -c 1 -W 1 ${t} > /dev/null 2>&1)
#         echo -n " ${t} $result"
#     done
#     read
# }

install_sshpass_package()
{
  echo ""
  echo "     ---------------------------------------"
  echo ""
  echo "   Get the necessary packages... Please wait ... "
  echo ""
  apt-get install sshpass -y > /dev/null 2>&1
  RET_INSTALL=$?
  if [ "${RET_INSTALL}" -eq "${NORMAL_EXIT_ID}" ]
  then
    sshpass -V
  else
    if [ "${RET_INSTALL}" -eq "${SUDO_PRIVILEGE_NEEDED_ERROR}" ]
    then
      return "${SUDO_PRIVILEGE_NEEDED_ERROR}"
    else
      return "${SSHPASS_IS_NOT_INSTALLED_ID}"
    fi
  fi
  echo ""
  echo "     ---------------------------------------"
  echo ""
  return "${SSHPASS_IS_INSTALLED_ID}"
}

generating_rsa_key()
{
  echo
  echo "----------------------------"
  echo "---- Generating SSH KEY ----"
  echo "----------------------------"
  echo
  sudo -u ${USER_RUN} -H bash -c "ssh-keygen -f ${USER_HOME}/.ssh/id_rsa"    
  echo
  # add log file
}

config_rsa_key()
{
  echo
  echo "----------------------------"
  echo "--- Send SSH KEY to Host ---"
  echo " List Host ${TARGET_LIST}"
  echo "----------------------------"
  echo
  for host in ${TARGET_LIST}
  do
    TARGET_PASS=$(cat ${INVENTORY_FILE}  | grep ${host} | awk -F " " '{ print $4}' | awk -F "ansible_password=" '{ print $2}')
    TARGET_USER=$(cat ${INVENTORY_FILE}  | grep ${host} | awk -F " " '{ print $3}' | awk -F "ansible_user=" '{ print $2}')
    if [ ! -z ${host} ]
    then
      sudo -u ${USER_RUN} -H bash -c "sshpass -p ${TARGET_PASS} ssh-copy-id -i ${USER_HOME}/.ssh/id_rsa.pub ${TARGET_USER}@${host} -o StrictHostKeyChecking=no"
      RET_SSH_COPY_ID=$?
      if [ "${RET_SSH_COPY_ID}" -eq "${NORMAL_EXIT_ID}" ]
      then
        echo -e "${host} ${ACTION_OK}"
      else
        echo -e "${host} ${ACTION_KO}"
      fi
    fi
  done
  echo "------------------------------------------------------------"
}

show_inventory_file()
{
  INVENTORY_FILE=$1
  if [ ! -f ${INVENTORY_FILE} ]
  then
    return ${INVENTORY_FILE_NOT_FOUND_ID}
  fi
  TARGET_LIST=$(cat ${INVENTORY_FILE} | awk -F " " '{ print $2}' | awk -F "ansible_host=" '{ print $2}'| sort -u)
  echo
  echo "----------------------------"
  echo "Hosts found in the file : "
  echo "----------------------------"
  for i in $TARGET_LIST
  do
    if [ ! -z i ]
    then
      echo " - $i"
    fi
  done
  echo "----------------------------"
  return ${NORMAL_EXIT_ID}
}

get_list_target_host()
{
  echo
  echo "------------------------------------------------------------"
  echo "--- configure the authentication to the targets machines ---"
  echo "------------------------------------------------------------"
  echo
  echo " Please enter the path of the inventory file [ Default: ${INVENTORY_FILE_NAME_DEFAULT} ]"
  echo -n " > "
  read TMP_FILE
  if [ -z ${TMP_FILE} ]
  then
    INVENTORY_FILE=${INVENTORY_FILE_NAME_DEFAULT}
  else
    INVENTORY_FILE=${TMP_FILE}
  fi
  show_inventory_file ${INVENTORY_FILE}
  RET_SHOW_INVENTORY_FILE=$?
  if [ "${RET_SHOW_INVENTORY_FILE}" -eq "${INVENTORY_FILE_NOT_FOUND_ID}" ]
  then
    log "${INVENTORY_FILE_NOT_FOUND_ID}" "${INVENTORY_FILE_NOT_FOUND_MSG}"
    return ${INVENTORY_FILE_NOT_FOUND_ID}
  fi
  echo "------------------------------------------------------------"
  return ${NORMAL_EXIT_ID}
}

choice()
{
  ACTION=$1
  echo
  echo -e "Please enter your choice "
  echo -e "  enter (y/Y) for yes"
  echo -e "  anything else for no"
  echo -e ""
  echo -e -n " > "
  read CHOICE
  echo
  if [ "${CHOICE}" == "y" ] || [ "${CHOICE}" == "Y" ]
  then
    return ${ANSWER_POSITIVE}
  else
    return ${ANSWER_NEGATIVE}
  fi
}

get_input_user()
{
  echo "not impleùented yet"
}

get_user_run_info()
{
  USER_RUN_LIST=$(ls -l | awk -F " " '{print $3}' | sort -u)
  for u in ${USER_RUN_LIST} 
  do
    if [ ! -z ${u} ]
    then
      USER_RUN=${u}
    fi
  done
  USER_HOME=/home/${USER_RUN}

  echo -e " [ \033[1;4;32m${USER_RUN}\033[0m ] is the default user that will be used to configure the targets host with "
  echo " Do you want to change the user ? "
  choice
  RET_CHOICE=$?
  if [ "${RET_CHOICE}" -eq "${ANSWER_POSITIVE}" ]
  then
    get_input_user
    # manage the return of this function
  fi
  return ${NORMAL_EXIT_ID}
}


## atomic function 
## if we change the inventory file we should retry all the nexts actions
ssh_config() 
{
  for (( ; ; ))
  do 
    get_list_target_host
    RET_GET_LIST_TARGET_HOST=$?
    if [ "${RET_GET_LIST_TARGET_HOST}" -eq "${INVENTORY_FILE_NOT_FOUND_ID}" ]
    then
      echo "Do you want to retry ? "
      choice
      RET_CHOICE=$?
      if [ "${RET_CHOICE}" -eq "${ANSWER_POSITIVE}" ]
      then
        wait_msg
        clear
      else
        echo "not Retry  exit"
        exit ${NORMAL_EXIT_ID}
      fi
    else
      # break
      install_sshpass_package
      RET_INSTALL_SSHPASS_PACKAGE=$?
      if [ "${RET_INSTALL_SSHPASS_PACKAGE}" -eq "${SUDO_PRIVILEGE_NEEDED_ERROR}" ]
      then
        log "${ACTION_KO}" "${INSTALL_SSHPASS_MSG}" "${SUDO_PRIVILEGE_NEEDED_ERROR}"
    
        echo "to do : found a solution for sudo in run, not yet implemented ..."

        exit ${SUDO_PRIVILEGE_NEEDED_ERROR}
      elif [ "${RET_INSTALL_SSHPASS_PACKAGE}" -eq "${SSHPASS_IS_NOT_INSTALLED_ID}" ]
      then
        log "${ACTION_KO}" "${INSTALL_SSHPASS_MSG}" 
        exit ${SSHPASS_IS_NOT_INSTALLED_ID}
      else
        log "${ACTION_OK}" "${INSTALL_SSHPASS_MSG}"


        get_user_run_info
        RET_GET_USER_RUN_INFO=$?
        if [ "${RET_GET_USER_RUN_INFO}" -eq "${NORMAL_EXIT_ID}" ]
        then

          generating_rsa_key

          config_rsa_key
        # elif [ "${RET_GET_USER_RUN_INFO}" -eq "${}" ]
        # then


        # else
          break
        fi
      fi
    fi

  done

  return ${NORMAL_EXIT_ID}

}

main()
{
  clear
  echo
  echo "    -----------------------------------------"
  echo "    --- Configure The Ansible Environment ---"
  echo "    -----------------------------------------"
  echo

  setup_ansible
  RET_SETUP_ANSIBLE=$?
  if [ "${RET_SETUP_ANSIBLE}" -eq "${ANSIBLE_IS_INSTALLED_ID}" ]
  then
    echo
    echo
    echo    "      ------------------------------------"
    echo
    echo -e "           \033[0;32mAnsible is working correctly\033[0m"
    echo
    echo    "      ------------------------------------"
    echo

    echo    "  You can now configure your target machines"

    ask_choice
    RET_ASK_CHOICE=$?
    if [[ "${RET_ASK_CHOICE}" -eq "${ANSWER_POSITIVE}" ]]
    then
      ssh_config
      RET_SSH_CONFIG=$?
      if [[ "${RET_SSH_CONFIG}" -ne "${NORMAL_EXIT_ID}" ]]
      then
        echo erreur configuratuin ssh 
        return ${RET_SSH_CONFIG}
      fi        
    fi        
  else
    return "${RET_SETUP_ANSIBLE}"
  fi

  echo
  echo "You have finished configuring Ansible on your machine, Please wait, the program will exit"
  echo -n "Please click enter to continue > "
  read
  echo "Ciao"
  sleep 0.5
  wait_msg
  clear
  exit 0
}

EXE_MANE=$0

main