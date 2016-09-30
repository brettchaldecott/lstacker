#!/bin/bash



function add_host {
	if [ "$#" -ne 3 ]; then
		echo_std_out "[add_host]Illegal number of parameters"
		echo_std_out "arguments <fqdn> <ip_address> <container_network>"
		echo_std_out "Got: $@"
		exit -1
	fi

	local fqdn=$3
	local ip_address=$4
	local container_network=$5

	# create the host directory
	if [ ! -d ${HOSTS_DIRECTORY} ] ; then
		mkdir ${HOSTS_DIRECTORY}
	fi

	# create the container network file
	fprint "%s\t%s\n" "${ip_address}" "${fqdn}" | tee -a "${HOSTS_DIRECTORY}/${container_network}_hosts"
	fprint "%s\t%s\n" "${ip_address}" "${fqdn}" | tee -a "${HOSTS_DIRECTORY}/hosts"

}
