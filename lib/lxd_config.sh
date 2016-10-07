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
# Responsible for LXD config setup
#

# this function is called to register servers
function lxd_config_register_servers {
	local servers=${yml_lstack_servers_names[@]}
	if [ -z "${servers[@]}" ] ; then
		echo_std_out "Must provide the lstack_server_names configuration"
		exit -1
	fi
	local password=${yml_lstack_lxd_password[0]:-}
	if [ -z "${password}" ] ; then
		echo_std_out "Must provide the password"
		exit -1
	fi

	# configure lxd to expose the management port and set the password
	for lxd_config_register_server in ${servers[@]} ; do
		local server_name=`lxd_config_get_server_name "${lxd_config_register_server}"`
		if [ ! $? ] ; then
			echo_std_out "Failed to retrieve the server name for ${lxd_config_register_server}"
			continue
		fi
		# set the port
		cli_execute_command "${server_name}" "sudo lxc config set core.https_address [::]"
		# set the password
		cli_execute_command "${server_name}" "sudo lxc config set core.trust_password \"${password}\""
	done

	# register the servers so the interconnects work between them
	for lxd_config_register_server in ${servers[@]} ; do
		local server_name=`lxd_config_get_server_name "${lxd_config_register_server}"`
		if [ ! $? ] ; then
			echo_std_out "Failed to retrieve the server name for ${lxd_config_register_server}"
			continue
		fi
		# loop through the target servers for the management server
		local targets_servers=(${yml_lstack_servers_names[@]})
		for lxd_config_target_server in ${targets_servers[@]} ; do
			if [ "${lxd_config_register_server}" == "${lxd_config_target_server}" ] ; then
				continue
			fi
			# retrieve the target ip addresses
			eval "declare -a lxd_config_target_server_ip=(`get_yaml_config_var servers "${lxd_config_target_server}" ip`)"
			if [ ! $? ] ; then
				echo_std_out "Failed to retrieve the ip for ${lxd_config_target_server}"
				continue
			fi
			
			# add the remote server
			cli_execute_command "${server_name}" "sudo lxc remote add ${lxd_config_target_server} ${lxd_config_target_server_ip} --accept-certificate --password=\"${password}\""
		done
	done
}

# this function will clear all the profiles on the network
function lxd_config_de_register_servers {
	local servers=${yml_lstack_servers_names[@]}
	if [ -z "${servers[@]}" ] ; then
		echo_std_out "Must provide the lstack_server_names configuration"
		exit -1
	fi

	# setup lxc profiles for networks
	for lxd_config_de_register_server in ${servers[@]} ; do
		local server_name=`lxd_config_get_server_name "${lxd_config_de_register_server}"`
		if [ ! $? ] ; then
			echo_std_out "Failed to retrieve the server name for ${lxd_config_de_register_server}"
			continue
		fi
		local targets_servers=(${yml_lstack_servers_names[@]})
		for lxd_config_target_server in ${targets_servers[@]} ; do
			if [ "${lxd_config_register_server}" == "${lxd_config_target_server}" ] ; then
				continue
			fi
			
			cli_execute_command "${server_name}" "sudo lxc remote remove ${lxd_config_target_server}"
		done
	done

}

# function to get the server name for the provided server
function lxd_config_get_server_name {
	# validate import
	if [ "$#" -ne 1 ]; then
		echo_std_out "Illegal number of parameters"
		echo_std_out "arguments <server_name>"
		exit -1
	fi

	local server=$1

	# retrieve the server configuration
	local yaml_name_var_name="yml_lstack_servers_${server}_name"[@]
	local yaml_name_var=(${!yaml_name_var_name})
	if [ -z "${yaml_name_var[@]}" ] ; then
		echo_std_out "No name information for the server [${server}]"
		exit -1
	fi
	echo "${yaml_name_var[0]}"
	return 0
}
