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
# The network management scripts
#


# setup the network
function network_setup_network {
	echo_std_out "Setup network"

	# setup gre bridge
	local master_switch=${yml_lstack_networks_master_switch_server[0]}
	if [ -z ${master_switch} ] ; then
		echo_std_out "Must provide the lstack_networks_master_switch_server configuration"
		exit -1
	fi
	local servers=${yml_lstack_servers_names[@]}
	if [ -z ${master_switch} ] ; then
		echo_std_out "Must provide the lstack_server_names configuration"
		exit -1
	fi

	# setup lxc profiles for networks
	for network_setup_server in ${servers[@]} ; do
		# retrieve the server configuration
		echo "The network setup server ${network_setup_server}"
		local yaml_ip_var_name="yml_lstack_servers_${network_setup_server}_ip"
		local yaml_ip_var=${!yaml_ip_var_name}
		if [ -z ${yaml_ip_var} ] ; then
			echo_std_out "No ip information for the server [${network_setup_server}]"
			exit -1
		fi
		local yaml_name_var_name="yml_lstack_servers_${network_setup_server}_name"
		local yaml_name_var=${!yaml_name_var_name}
		if [ -z ${yaml_name_var} ] ; then
			echo_std_out "No name information for the server [${network_setup_server}]"
			exit -1
		fi
		
		echo "Setup the network for ${yaml_name_var}:${yaml_ip_var}"
		if [ "${network_setup_server}" == "${master_switch}" ] ; then
			declare -a network_setup_ip_array
			local network_server_names=${yaml_lstack_names[@]}
			for network_setup_target_server in ${network_server_names} ; do
				if [ "${network_setup_server}" == "${network_setup_target_server}" ] ; then
					continue
				fi
				local yaml_ip_target_var_name="yml_lstack_servers_${network_setup_target_server}_ip"
				local yaml_ip_target_var="${!yaml_ip_target_var_name}"
				if [ -z ${yaml_ip_target_var} ] ; then
					echo_std_out "No target ip was supplied for [${network_setup_target_server}]"
					exit -1
				fi
				network_setup_ip_array+=("${yaml_ip_target_var}")
			done

			openvswitch_create_bridge "${yaml_name_var}" network_setup_ip_array[@]
		else
			local yaml_ip_master_var_name="yml_lstack_servers_${network_setup_server}_ip"
			local yaml_ip_master_var="${!yaml_ip_master_var_name}"
			if [ -z ${yaml_ip_master_var} ] ; then
				echo_std_out "No master ip was supplied for [${network_setup_server}]"
				exit -1
			fi
			declare -a network_setup_ip_array=("${yaml_ip_master_var}")
			openvswitch_create_bridge "${yaml_name_var}" network_setup_ip_array[@]
		fi
		echo "After settup network on ${yaml_name_var}:${yaml_ip_var}"
	done
}


# function to clear the networking
function network_clear_network {
	echo_std_out "Clear network"

	# retrieve the yml server names that have to cleared
	local servers=${yml_lstack_servers_names[@]}
	if [ -z ${master_switch} ] ; then
		echo_std_out "Must provide the lstack_server_names configuration"
		exit -1
	fi


	# setup lxc profiles for networks
	for network_setup_server in servers[@] ; do
		local yaml_name_var_name="yml_lstack_servers_${network_setup_server}_name"
		local yaml_name_var=${!yaml_name_var_name}
		if [ -z yaml_name_var ] ; then
			echo_std_out "No name information for the server [${network_setup_server}]"
			exit -1
		fi
		openvswitch_destroy_bridge "${yaml_name_var}"
	done
}


