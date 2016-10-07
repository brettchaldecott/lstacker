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
# Responsible for managing LXD profiles
#

# this function is responsible for creating a network profile
function lxd_profile_create_network_profile {
	# validate import
	if [ "$#" -ne 2 ]; then
		echo_std_out "Illegal number of parameters"
		echo_std_out "arguments <host> <network_device_number>"
		exit -1
	fi
	
	local host=$1
	local device_number=$2
	local profile_name="${ETH_PROFILE_NAME}${device_number}"

	# create the profile
	cli_execute_command ${host} "sudo lxc profile create ${profile_name}"

	read -r -d '' lxd_network_profile <<- EOF
	name: ${profile_name}
	config: {}
	description: ${profile_name}
	devices:
	  eth${device_number}:
	    name: eth${device_number}
	    nictype: bridged
	    parent: ${BRIDGE_NAME}
	    type: nic
	EOF
	
	# edit the profile
	cli_execute_command_with_input "${host}" "sudo lxc profile edit ${profile_name}" "${lxd_network_profile}"

}

# this function is responsible for creating a network profile
function lxd_profile_delete_network_profile {
	# validate import
	if [ "$#" -ne 2 ]; then
		echo_std_out "Illegal number of parameters"
		echo_std_out "arguments <host> <network_device_number>"
		exit -1
	fi
	
	local host=$1
	local device_number=$2
	local profile_name="${ETH_PROFILE_NAME}${device_number}"

	# create the profile
	cli_execute_command ${host} "sudo lxc profile delete ${profile_name}"

}

# this function will create all the profiles on the network
function lxd_profile_create_network_profiles {
	local servers=${yml_lstack_servers_names[@]}
	if [ -z "${servers[@]}" ] ; then
		echo_std_out "Must provide the lstack_server_names configuration"
		exit -1
	fi

	# setup lxc profiles for networks
	for network_setup_server in ${servers[@]} ; do
		# retrieve the server configuration
		local yaml_name_var_name="yml_lstack_servers_${network_setup_server}_name"
		local yaml_name_var=${!yaml_name_var_name}
		if [ -z "${yaml_name_var[@]}" ] ; then
			echo_std_out "No name information for the server [${network_setup_server}]"
			exit -1
		fi
		local device_number=1
		local network_names=${yml_lstack_networks_names[@]}
		for lxd_profile_network in ${network_names[@]} ; do
			lxd_profile_create_network_profile "${yaml_name_var[0]}" ${device_number}
			((++device_number))
		done
	done
}

# this function will clear all the profiles on the network
function lxd_profile_clear_network_profiles {
	local servers=${yml_lstack_servers_names[@]}
	if [ -z "${servers[@]}" ] ; then
		echo_std_out "Must provide the lstack_server_names configuration"
		exit -1
	fi

	# clear lxc profiles for networks
	for network_setup_server in ${servers[@]} ; do
		# retrieve the server configuration
		local yaml_name_var_name="yml_lstack_servers_${network_setup_server}_name"
		local yaml_name_var=${!yaml_name_var_name}
		if [ -z "${yaml_name_var[@]}" ] ; then
			echo_std_out "No name information for the server [${network_setup_server}]"
			exit -1
		fi
		local device_number=1
		local network_names=${yml_lstack_networks_names[@]}
		for lxd_profile_network in ${network_names[@]} ; do
			lxd_profile_delete_network_profile "${yaml_name_var[0]}" ${device_number}
			((++device_number))
		done
	done
}
