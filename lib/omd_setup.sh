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
# The omd setup script
#

# setup the omd directory information
OMD_DIRECTORY="${LSTACKER_CONTEXT}/omd"
OMD_WATO_HOSTS="${OMD_DIRECTORY}/wato_hosts"
OMD_WATO_HOSTS_ATTRIBUTES="${OMD_DIRECTORY}/wato_hosts_attributes"
OMD_WATO_FILE="${OMD_DIRECTORY}/.wato"
OMD_WATO_HOST_FILE="${OMD_DIRECTORY}/hosts.mk"

# add hosts
function omd_setup_add_host {
	# validate import
	if [ "$#" -ne 1 ]; then
		echo_std_out "Illegal number of parameters"
		echo_std_out "arguments <host>"
		exit -1
	fi
	local host=$1
	echo "Add a host entry to omd ${host}"

	read -r -d '' omd_setup_host_line <<- EOF
	  "${host}|cmk-agent|prod|lan|tcp|wato|/" + FOLDER_PATH + "/",
	EOF
	
	echo "echo ${omd_setup_host_line} | tee -a ${OMD_WATO_HOSTS}"
	echo "${omd_setup_host_line}" | tee -a ${OMD_WATO_HOSTS}

	read -r -d '' omd_setup_host_attribute_line <<- EOF
	  '${host}': {},
	EOF
	
	echo "echo ${omd_setup_host_attribute_line} | tee -a ${OMD_WATO_HOSTS_ATTRIBUTES}"
	echo "${omd_setup_host_attribute_line}" | tee -a ${OMD_WATO_HOSTS_ATTRIBUTES}

}

# setup the wato file
function omd_setup_create_wato_file {
	# validate import
	if [ "$#" -ne 3 ]; then
		echo_std_out "Illegal number of parameters"
		echo_std_out "arguments <lxd_host> <container> <network>"
		exit -1
	fi
	local host=$1
	local container=$2
	local network=$3

	# create the omd directory
	if [ ! -d ${OMD_DIRECTORY} ] ; then
		mkdir -p ${OMD_DIRECTORY}
	fi


	# loop through the hosts file created for the network
	local network_hosts_file="${HOSTS_DIRECTORY}/${network}_hosts"
	local host_count=0
	while read -r -u 11 omd_setup_setup_line; do
		local host_info=(${omd_setup_setup_line})
		omd_setup_add_host "${host_info[1]}"
		((host_count++))
	done 11<${network_hosts_file};

	# create the wato file
	read -r -d '' omd_setup_wato_file_contents <<- EOF
	{'attributes': {}, 'num_hosts': ${host_count}, 'title': u'${network}'}
	EOF
	echo "echo ${omd_setup_wato_file_contents} | tee -a ${OMD_WATO_FILE}"
	echo "${omd_setup_wato_file_contents}" | tee -a ${OMD_WATO_FILE}

	# create the hosts file
	read -r -d '' omd_setup_wato_prefix <<- EOF
	# Written by lstacker
	# encoding: utf-8

	all_hosts += [
	EOF
	echo "echo ${omd_setup_wato_prefix} | tee -a ${OMD_WATO_HOST_FILE}"
	echo "${omd_setup_wato_prefix}" | tee -a ${OMD_WATO_HOST_FILE}
	cat ${OMD_WATO_HOSTS} | tee -a ${OMD_WATO_HOST_FILE}

	read -r -d '' omd_setup_wato_middle <<- EOF
	]


	# Host attributes (need for WATO)
	host_attributes.update({
	EOF
	echo "echo ${omd_setup_wato_middle} | tee -a ${OMD_WATO_HOST_FILE}"
	echo "${omd_setup_wato_middle}" | tee -a ${OMD_WATO_HOST_FILE}
	cat ${OMD_WATO_HOSTS_ATTRIBUTES} | tee -a ${OMD_WATO_HOST_FILE}

	read -r -d '' omd_setup_wato_suffix <<- EOF
	})
	EOF
	echo "echo ${omd_setup_wato_suffix} | tee -a ${OMD_WATO_HOST_FILE}"
	echo "${omd_setup_wato_suffix}" | tee -a ${OMD_WATO_HOST_FILE}

}


# setup monitoring
function omd_setup_setup_monitoring {
	local host="${yml_lstack_monitoring_server:-}"
	local container="${yml_lstack_monitoring_container:-}"
	local network="${yml_lstack_monitoring_network:-}"
	local omd_name="${yml_lstack_monitoring_name:-}"
	if [ -z "${host}" ] || [ -z "${container}" ] || [ -z "${network}" ] || [ -z "${omd_name}" ]; then
		echo_std_out "Must provide the following monitoring configuration"
		echo_std_out "yml:lstack:monitoring:server: lxd server"
		echo_std_out "yml:lstack:monitoring:container: container name"
		echo_std_out "yml:lstack:monitoring:container: network"
		exit -1
	fi

	omd_setup_create_wato_file "${host}" "${container}" "${network}"

	# create the wato network folder and copy the files into place
	local wato_remote_directory="/omd/sites/${omd_name}/etc/check_mk/conf.d/wato/${network}"
	lxd_execute_command "${host}" "${container}" "mkdir -p ${wato_remote_directory}"
	lxd_file_copy "${host}" "${container}" "${OMD_WATO_FILE}" "${wato_remote_directory}/.wato"
	lxd_file_copy "${host}" "${container}" "${OMD_WATO_HOST_FILE}" "${wato_remote_directory}/hosts.mk"
	lxd_execute_command "${host}" "${container}" "chown -R ${omd_name}:${omd_name} ${wato_remote_directory}"

}


function omd_setup_clear_monitoring {
	# create the omd directory
	if [ -d ${OMD_DIRECTORY} ] ; then
		rm -rf ${OMD_DIRECTORY}
	fi
}
