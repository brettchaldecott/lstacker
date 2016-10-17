#!/bin/bash



function hosts_add_host {
	if [ "$#" -ne 3 ]; then
		echo_std_out "[add_host]Illegal number of parameters"
		echo_std_out "arguments <fqdn> <ip_address> <container_network>"
		echo_std_out "Got: $@"
		exit -1
	fi

	local fqdn=$1
	local ip_address=$2
	local container_network=$3

	# create the host directory
	if [ ! -d ${HOSTS_DIRECTORY} ] ; then
		mkdir ${HOSTS_DIRECTORY}
	fi

	# remove lines from file
	sed -i "/^.*${fqdn}/d" "${HOSTS_DIRECTORY}/${container_network}_hosts"
	sed -i "/^.*${fqdn}/d" "${HOSTS_DIRECTORY}/hosts"

	# create the container network file
	printf "%s\t%s\n" "${ip_address}" "${fqdn}" | tee -a "${HOSTS_DIRECTORY}/${container_network}_hosts"
	printf "%s\t%s\n" "${ip_address}" "${fqdn}" | tee -a "${HOSTS_DIRECTORY}/hosts"

}

function hosts_set_hosts_on_container {
	if [ "$#" -ne 2 ]; then
		echo_std_out "[hosts_set_hosts_on_container] Illegal number of parameters"
		echo_std_out "arguments <host> <container>"
		echo_std_out "Got: $@"
		exit -1
	fi
	local host=$1
	local container=$2
	local yaml_container=${container/-/_}

	eval "declare -a hosts_networks=(`get_yaml_config_var ${host} ${yaml_container} networks`)"
	eval "declare -a hosts_lxd_server=(`get_yaml_config_var servers ${host} name`)"
	
	for hosts_network in ${hosts_networks[@]} ; do
		echo "Set hosts ${hosts_network} on ${host}:${container}"
		lxd_file_append "${hosts_lxd_server}" "${container}" "${HOSTS_DIRECTORY}/${hosts_network}_hosts" "/etc/hosts"
	done

}

function hosts_set_hosts_on_host {
	if [ "$#" -ne 1 ]; then
		echo_std_out "[hosts_set_hosts_on_host] Illegal number of parameters"
		echo_std_out "arguments <host>"
		echo_std_out "Got: $@"
		exit -1
	fi
	local host=$1
	echo "Set hosts on the server ${host}"
	eval "declare -a hosts_lxd_containers_for_host=(`get_yaml_config_var ${host} hosts`)"
	echo "The list of containers on host ${host} ${hosts_lxd_containers_for_host[@]}"
	for hosts_lxd_container in ${hosts_lxd_containers_for_host[@]} ; do
		echo "Set the hosts on container ${host} ${hosts_lxd_container}"
		hosts_set_hosts_on_container "${host}" "${hosts_lxd_container}"
	done

}

function hosts_set_hosts {

	local hosts_array=${yml_lstack_servers_names[@]}
	for hosts_lxd_host in ${hosts_array[@]} ; do
		echo "Set the hosts on the containers on ${hosts_lxd_host}"
		hosts_set_hosts_on_host "${hosts_lxd_host}"
	done
}

function hosts_clear_hosts {
	# clear the hosts directory 
	if [ -d "${HOSTS_DIRECTORY}" ] ; then
		echo "Clear the hosts directory ${HOSTS_DIRECTORY}"
		rm -f ${HOSTS_DIRECTORY}/*
		local delete_result=$?
		echo "After clearing the hosts directory ${HOSTS_DIRECTORY} ${delete_result}"
	else
		echo "The directory ${HOSTS_DIRECTORY} does not exist"
	fi

}
