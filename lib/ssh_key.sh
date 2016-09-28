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

# set the ssh keys on a box
function set_public_key {
	if [ "$#" -ne 4 ]; then
		echo_std_out "Illegal number of parameters"
		echo_std_out "arguments <linux> <lxd_host> <lxd_container> <public_key_file>"
		exit -1
	fi
	local linux=$1
	local lxd_host=$2
	local lxd_container=$3
	local ssh_public_key_file=$4
	echo_std_out "The keys is ${ssh_public_key_file}"

	if [ ${linux} == ubuntu ]; then
		lxd_file_copy ${container_lxd_server} ${container_hostname} ${ssh_public_key_file} "${DISTRO_DEFAULT_HOME["${linux}"]}/.ssh/authorized_keys"
	elif [ ${linux} == centos ]; then
		lxd_execute_command ${container_lxd_server} ${container_hostname} "mkdir -p ${DISTRO_DEFAULT_HOME["${linux}"]}/.ssh/"
		lxd_file_append ${container_lxd_server} ${container_hostname} ${ssh_public_key_file} "${DISTRO_DEFAULT_HOME["${linux}"]}/.ssh/authorized_keys"
	fi

}
