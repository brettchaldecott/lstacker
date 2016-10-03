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


# this method is called to create a container
function container_create_container {
	# validate import
	if [ "$#" -ne 2 ]; then
		echo_std_out "Illegal number of parameters"
		echo_std_out "arguments <host> <container>"
		exit -1
	fi

	local lxd_host=$1
	local container=$2
	local yaml_container=${container/-/_}

	# retrieve the yaml configuration
	if ! has_yaml_config_var servers ${lxd_host} name ; then
		echo_std_out "LXD host ${lxd_host} not found"
		exit -1
	fi
	eval "declare -a container_lxd_server=(`get_yaml_config_var servers ${lxd_host} name`)"
	if ! has_yaml_config_var ${lxd_host} ${yaml_container} host ; then
		echo_std_out "Container ${lxd_host}:${container} not found"
		exit -1
	fi
	eval "declare -a container_hostname=(`get_yaml_config_var ${lxd_host} ${yaml_container} host`)"
	eval "declare -a container_networks=(`get_yaml_config_var ${lxd_host} ${yaml_container} networks`)"
	eval "declare -a container_ip_suffix=(`get_yaml_config_var ${lxd_host} ${yaml_container} ip_suffix`)"
	eval "declare -a container_linux_distro=(`get_yaml_config_var ${lxd_host} ${yaml_container} linux_distro`)"
	eval "declare -a container_distro_version=(`get_yaml_config_var ${lxd_host} ${yaml_container} distro_version`)"
	eval "declare -a container_lxd_profiles=(`get_yaml_config_var ${lxd_host} ${yaml_container} lxd_profiles`)"

	# duplicate the container profiles and add the extra network profiles assuming a name
	container_profiles=("${container_lxd_profiles[@]}")
	local eth_dev_count=1
	for container_network in ${container_networks[@]} ; do
		container_profiles+=("${ETH_PROFILE_NAME}${eth_dev_count}")
		((++eth_dev_count))
	done

	# create the container
	lxd_create_container ${container_linux_distro[0]} ${container_distro_version[0]} ${container_lxd_server} ${container_hostname} container_profiles[@]

	sleep ${CONTAINER_WAIT_DELAY}

	# setup the networking
	local eth_dev_count=1
	for container_network in ${container_networks[@]} ; do
		# retrieve the block for the container network
		eval "declare -a container_network_block=(`get_yaml_config_var networks ${container_network} network`)"
		eval "declare -a container_network_domain=(`get_yaml_config_var networks ${container_network} domain`)"
		eval "declare -a container_ip_segment=(`get_yaml_config_var servers ${lxd_host} ip_segment`)"
		local eth_device="eth${eth_dev_count}"
		local address="${container_network_block}.${container_ip_segment}.${container_ip_suffix}"
		local fqdn="${container_hostname}.${container_network_domain}"
		add_eth ${container_linux_distro[0]} ${container_lxd_server} ${container_hostname} ${eth_device} ${address} ${container_network_block}
		add_host "${fqdn}" "${address}" "${container_network}"
		((++eth_dev_count))
	done

	# setup a proxy
	if has_yaml_config_var proxy state ; then
		eval "declare -a container_proxy_state=(`get_yaml_config_var proxy state`)"
		if [ "${container_proxy_state[0]}" == "yes" ] ; then
			eval "declare -a container_proxy_http_url=(`get_yaml_config_var proxy http_url`)"
			eval "declare -a container_proxy_https_url=(`get_yaml_config_var proxy https_url`)"
			configure_proxy ${container_linux_distro[0]} ${container_distro_version[0]} ${container_lxd_server} ${container_hostname} ${container_proxy_http_url[0]} ${container_proxy_https_url[0]}
		fi
	fi

	# set the keys
	if has_yaml_config_var ssh public_keys ; then
		eval "declare -a container_public_keys=(`get_yaml_config_var ssh public_keys`)"
		for container_public_key in ${container_public_keys[@]} ; do
			set_public_key ${container_linux_distro[0]} ${container_lxd_server} ${container_hostname} "${container_public_key[@]}" 
		done
	fi

	# apply the recipes to the new instances
	if has_yaml_config_var ${lxd_host} ${yaml_container} recipies ; then
		eval "declare -a container_recipies=(`get_yaml_config_var ${lxd_host} ${yaml_container} recipies`)"
		for container_recipe in ${container_recipies[@]} ; do
			apply_recipe ${container_linux_distro[0]} ${container_distro_version[0]} ${container_lxd_server} ${container_hostname} ${container_recipe}
		done
	fi

	echo_std_out "Created the container ${container}"
}

function container_destroy_container {
	if [ "$#" -ne 2 ]; then
		echo_std_out "Illegal number of parameters"
		echo_std_out "arguments <host> <container>"
		exit -1
	fi

	local lxd_host=$1
	local container=$2
	local yaml_container=${container/-/_}

	if ! has_yaml_config_var servers ${lxd_host} name ; then
		echo_std_out "LXD host ${lxd_host} not found"
		exit -1
	fi
	eval "declare -a container_lxd_server=(`get_yaml_config_var servers ${lxd_host} name`)"
	if ! has_yaml_config_var ${lxd_host} ${yaml_container} host ; then
		echo_std_out "Container ${lxd_host}:${container} not found"
		exit -1
	fi
	eval "declare -a container_hostname=(`get_yaml_config_var ${lxd_host} ${yaml_container} host`)"
	lxd_destroy_container ${container_lxd_server} ${container_hostname}
	echo_std_out "Destroyed the container ${container}"
}

# create a container
function container_create_containers_on_host {
	if [ "$#" -ne 1 ]; then
		echo_std_out "Illegal number of parameters"
		echo_std_out "arguments <host>"
		exit -1
	fi

	local lxd_host=$1
	echo "Create the containers on host ${lxd_host}"
	eval "declare -a container_lxd_containers_for_host=(`get_yaml_config_var ${lxd_host} hosts`)"
	declare -a container_create_container_pid_array
	echo "The list of containers on host ${lxd_host} ${container_lxd_containers_for_host[@]}"
	for container_lxd_container in ${container_lxd_containers_for_host[@]} ; do
		echo "Create the container ${lxd_host} ${container_lxd_container}"
		container_create_container "${lxd_host}" "${container_lxd_container}" &
		container_create_container_pid_array+=($!)
	done

	for container_create_container_pid in ${container_create_container_pid_array[@]} ; do
		echo "Wait for the pid ${container_create_container_pid}"
		wait ${container_create_container_pid}
	done
	echo "Create complete"

}

# destroy a container
function container_destroy_containers_on_host {
	if [ "$#" -ne 1 ] ; then
		echo_std_out "Illegal number of parameters"
		echo_std_out "arguments <host>"
		exit -1
	fi

	local lxd_host=$1
	eval "declare -a container_lxd_containers_for_host=(`get_yaml_config_var ${lxd_host} hosts`)"
	declare -a container_destory_container_pid_array
	echo "The list of containers on host ${lxd_host} ${container_lxd_containers_for_host[@]}"
	for container_lxd_container in ${container_lxd_containers_for_host[@]} ; do
		echo "Destroy the container ${lxd_host} ${container_lxd_container}"
		container_destory_container "${lxd_host}" "${container_lxd_container}" &
		container_destroy_container_pid_array+=($!)
	done
	
	for container_destory_container_pid in ${container_destory_container_pid_array[@]} ; do
		wait ${container_destroy_container_pid}
	done
}


# this function creates the containers accross the network but it does it asynchronisly and waits
# for the pid's to stop processing
function container_create_containers {

	local container_lxd_hosts_array=${yml_lstack_servers_names[@]}
	declare -a container_create_containers_on_host_pid_array
	for container_lxd_host in ${container_lxd_hosts_array[@]} ; do
		echo "Create the containers on host ${container_lxd_host}"
		container_create_containers_on_host "${container_lxd_host}" &
		container_create_containers_on_host_pid_array+=($!)
	done

	for container_create_container_pid in ${container_create_containers_on_host_pid_array[@]} ; do
		wait ${container_create_container_pid}
	done

}


# this function destory the containers accross the network but it does it asynchronisly and waits
# for the pid's to stop processing
function container_destory_containers {

	local container_lxd_hosts_array=${yml_lstack_servers_names[@]}
	declare -a container_destroy_containers_on_host_pid_array
	for container_lxd_host in ${container_lxd_hosts_array[@]} ; do
		echo "Destroy the containers on host ${container_lxd_host}"
		container_destroy_containers_on_host "${container_lxd_host}" &
		container_destroy_containers_on_host_pid_array+=($!)
	done

	for container_destory_container_pid in ${container_destroy_containers_on_host_pid_array[@]} ; do
		wait ${container_destroy_container_pid}
	done

}
