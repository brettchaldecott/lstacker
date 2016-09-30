#!/bin/bash
#
# Copyright 2016-09 brett.chaldecott@gmail.com
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
#     Unless required by applicable law or agreed to in writing, software
#     distributed under the License is distributed on an "AS IS" BASIS,
#     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#     See the License for the specific language governing permissions and
#     limitations under the License.
#
#
# The ssh wrapper
#

# this method is used to execute a command
function ssh_execute_command {
	# validate import
	if [ "$#" -ne 2 ]; then
		echo_std_out "Illegal number of parameters"
		echo_std_out "arguments <server> <remote_command>"
		exit -1
	fi

	local server=$1
	local remote_command=$2
	local key_file=${yml_lstack_ssh_private_key_file[0]}
	local ssh_user=${yml_lstack_ssh_username[0]}
	ssh_check_key_file ${key_file}
	ssh_check_username ${ssh_user}
	
	echo "ssh -i ${key_file} ${ssh_user}\@${server} \"${remote_command}\""
	local ssh_result=`ssh -i ${key_file} ${ssh_user}\@${server} "${remote_command}"`
	local command_result=$?
	echo "The result of the ssh: ${ssh_result}"
        if [ "${IGNORE_RESULTS}" -ne "0" ] && [ ${command_result} -ne 0 ] ; then
		echo_std_out "[ssh_execute_command] Failed to execute the command result"
		echo_std_out "ssh -i ${key_file} ${ssh_user}\@${server} \"${remote_command}\""
		exit -1
	fi

}

# this method is used to execute a command with an input string as source
function ssh_execute_command_with_input {
	# validate import
	if [ "$#" -ne 3 ]; then
		echo_std_out "Illegal number of parameters"
		echo_std_out "arguments <server> <remote_command> <input>"
		exit -1
	fi

	local server=$1
	local remote_command=$2
	local input=$3
	local key_file=${yml_lstack_ssh_private_key_file[0]}
	local ssh_user=${yml_lstack_ssh_username[0]}
	ssh_check_key_file ${key_file}
	ssh_check_username ${ssh_user}
	
	echo "echo \"${input}\" | ssh -i ${key_file} ${ssh_user}\@${server} \"${remote_command}\""
	local ssh_result=`echo "${input}" | ssh -i ${key_file} ${ssh_user}\@${server} "${remote_command}"`
	local command_result=$?
	echo "The result of the ssh: ${ssh_result}"
        if [ "${IGNORE_RESULTS}" -ne "0" ] && [ ${command_result} -ne 0 ] ; then
		echo_std_out "[ssh_execute_command] Failed to execute the command result"
		echo_std_out "echo \"${input}\" | ssh -i ${key_file} ${ssh_user}\@${server} \"${remote_command}\""
		exit -1
	fi

}

# this method is used to execute a command with an input file
function ssh_execute_command_with_file {
	# validate import
	if [ "$#" -ne 3 ]; then
		echo_std_out "Illegal number of parameters"
		echo_std_out "arguments <server> <remote_command> <input_file>"
		exit -1
	fi

	local server=$1
	local remote_command=$2
	local input_file=$3
	local key_file=${yml_lstack_ssh_private_key_file[0]}
	local ssh_user=${yml_lstack_ssh_username[0]}
	ssh_check_key_file ${key_file}
	ssh_check_username ${ssh_user}
	
	echo "cat \"${input_file}\" | ssh -i ${key_file} ${ssh_user}\@${server} \"${remote_command}\""
	local ssh_result=`cat "${input_file}" | ssh -i ${key_file} ${ssh_user}\@${server} "${remote_command}"`
	local command_result=$?
	echo "The result of the ssh: ${ssh_result}"
        if [ "${IGNORE_RESULTS}" -ne "0" ] && [ ${command_result} -ne 0 ] ; then
		echo_std_out "[ssh_execute_command] Failed to execute the command result"
		echo_std_out "cat \"${input_file}\" | ssh -i ${key_file} ${ssh_user}\@${server} \"${remote_command}\""
		exit -1
	fi

}

# a method to check the key file being used is correct
function ssh_check_key_file {
	# validate import
	if [ "$#" -ne 1 ]; then
		echo_std_out "Illegal number of parameters"
		echo_std_out "arguments <key_file>"
		exit -1
	fi
	local key_file=$1
	
	if [ -z ${key_file} ] ; then
		echo_std_out "No key file specified, please provide a valid private key"
		exit -1
	fi

	if [ ! -f ${key_file} ] ; then
		echo_std_out "The key file path ${key_file} does not point at a valid file"
		exit -1
	fi
	
}

# a method to validate the username
function ssh_check_username {
	# validate import
	if [ "$#" -ne 1 ]; then
		echo_std_out "Illegal number of parameters"
		echo_std_out "arguments <username>"
		exit -1
	fi
	local username=$1
	
	if [ -z ${username} ] ; then
		echo_std_out "No username was provided please provide one"
		exit -1
	fi

}
