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
# Code to wrap the calling of lxd container commands
#

# create a container
function lxd_create_container {
	if [ "$#" -ne 5 ]; then
		echo_std_out "[lxd_create_container] Illegal number of parameters"
		echo_std_out "arguments <linux> <linux_version> <lxd_host> <lxd_container> <profiles>"
		echo_std_out "Got [$#] $@"
		exit -1
	fi
	local linux=$1
	local linux_version=$2
	local lxd_host=$3
	local lxd_container=$4
	#local profiles=$5
	declare -a profiles=("${!5}")
	local profiles_str=""
	for profile in "${profiles[@]}" ; do
		profiles_str="$profiles_str -p ${profile}"
	done

	get_lxd_source lxd_create_linux_source ${linux} ${linux_version}
	get_lxd_image lxd_create_linux_image ${linux} ${linux_version}

	echo sudo lxc launch ${lxd_create_linux_source}:${lxd_create_linux_image} ${lxd_host}:${lxd_container} ${profiles_str}
	sudo lxc launch ${lxd_create_linux_source}:${lxd_create_linux_image} ${lxd_host}:${lxd_container} ${profiles_str}
	command_result=$?
        if [ "${IGNORE_RESULTS}" -ne "0" ] && [ ${command_result} -ne 0 ] ; then
		echo_std_out "[lxd_create_container] Failed to create the container"
		echo_std_out sudo lxc launch ${lxd_create_linux_source}:${lxd_create_linux_image} ${lxd_host}:${lxd_container} ${profiles_str}
		exit -1
	fi
}

# destroy a container
function lxd_destroy_container {
	if [ "$#" -ne 2 ]; then
		echo_std_out "Illegal number of parameters"
		echo_std_out "arguments <lxd_host> <lxd_container>"
		exit -1
	fi
	local lxd_host=$1
	local lxd_container=$2

	echo sudo lxc delete -f ${lxd_host}:${lxd_container}
	sudo lxc delete -f ${lxd_host}:${lxd_container}
	command_result=$?
        if [ "${IGNORE_RESULTS}" -ne "0" ] && [ ${command_result} -ne 0 ] ; then
		echo_std_out "[lxd_destroy_container] Failed to create the container"
		echo_std_out sudo lxc delete -f ${lxd_host}:${lxd_container}
		exit -1
	fi

}

# copy a file using lxd to the target container
function lxd_file_copy {
	if [ "$#" -ne 4 ]; then
		echo_std_out "Illegal number of parameters"
		echo_std_out "arguments <lxd_host> <lxd_container> <source_file> <target_file>"
		exit -1
	fi
	local lxd_host=$1
	local lxd_container=$2
	local source_file=$3
	local target_file=$4
	echo "cat ${source_file} | sudo lxc exec ${lxd_host}:${lxd_container} -- bash -c \" tee ${target_file}\""
	local result_command=`cat "${source_file}" | sudo lxc exec ${lxd_host}:${lxd_container} -- bash -c " tee ${target_file}"`
	local command_result=$?
	echo "Result of copy: ${result_command}"
        if [ "${IGNORE_RESULTS}" -ne "0" ] && [ ${command_result} -ne 0 ] ; then
		echo_std_out "[lxd_destroy_container] Failed to create the container"
		echo_std_out cat ${source_file} | sudo lxc exec ${lxd_host}:${lxd_container} -- bash -c " tee ${target_file}"
		exit -1
	fi
}

function lxd_file_append {
	if [ "$#" -ne 4 ]; then
		echo_std_out "[lxd_file_append] Illegal number of parameters"
		echo_std_out "arguments <lxd_host> <lxd_container> <source_file> <target_file>"
		exit -1
	fi
	local lxd_host=$1
	local lxd_container=$2
	local source_file=$3
	local target_file=$4
	echo "cat ${source_file} | sudo lxc exec ${lxd_host}:${lxd_container} -- bash -c \" tee -a ${target_file}\""
	local result_command=`cat "${source_file}" | sudo lxc exec ${lxd_host}:${lxd_container} -- bash -c " tee -a ${target_file}"`
	local command_result=$?
	echo "Result of append: ${result_command}"
        if [ "${IGNORE_RESULTS}" -ne "0" ] && [ ${command_result} -ne 0 ] ; then
		echo_std_out "[lxd_destroy_container] Failed to create the container"
		echo_std_out cat ${source_file} | sudo lxc exec ${lxd_host}:${lxd_container} -- bash -c " tee -a ${target_file}"
		exit -1
	fi
}

# string to file using lxd to the target container
function lxd_string_to_file {
	if [ "$#" -ne 4 ]; then
		echo_std_out "[lxd_string_to_file] Illegal number of parameters"
		echo_std_out "arguments <lxd_host> <lxd_container> <source_str> <target_file>"
		echo_std_out "got $@"
		exit -1
	fi
	local lxd_host=$1
	local lxd_container=$2
	local source_str=$3
	local target_file=$4
	echo "echo ${source_str} | sudo lxc exec ${lxd_host}:${lxd_container} -- bash -c \" tee ${target_file}\""
	echo "${source_str}" | sudo lxc exec ${lxd_host}:${lxd_container} -- bash -c " tee ${target_file}"
	command_result=$?
        if [ "${IGNORE_RESULTS}" -ne "0" ] && [ ${command_result} -ne 0 ] ; then
		echo_std_out "[lxd_destroy_container] Failed to create the container"
		echo_std_out echo ${source_str} | sudo lxc exec ${lxd_host}:${lxd_container} -- bash -c " tee ${target_file}"
		exit -1
	fi
}

function lxd_string_to_file_append {
	if [ "$#" -ne 4 ]; then
		echo_std_out "[lxd_string_to_file_append] Illegal number of parameters"
		echo_std_out "arguments <lxd_host> <lxd_container> <source_str> <target_file>"
		echo_std_out "got $@"
		exit -1
	fi
	local lxd_host=$1
	local xd_container=$2
	source_str=$3
	target_file=$4
	echo "echo ${source_str} | sudo lxc exec ${lxd_host}:${lxd_container} -- bash -c \" tee -a ${target_file}\""
	echo "${source_str}" | sudo lxc exec ${lxd_host}:${lxd_container} -- bash -c " tee -a ${target_file}"
	command_result=$?
        if [ "${IGNORE_RESULTS}" -ne "0" ] && [ ${command_result} -ne 0 ] ; then
		echo_std_out "[lxd_destroy_container] Failed to create the container"
		echo_std_out echo ${source_str} | sudo lxc exec ${lxd_host}:${lxd_container} -- bash -c " tee -a ${target_file}"
		exit -1
	fi
}

# execute a command on the target system
function lxd_execute_command {
	if [ "$#" -ne 3 ]; then
		echo_std_out "[lxd_execute_command] Illegal number of parameters"
		echo_std_out "arguments <lxd_host> <lxd_container> <target_command>"
		echo_std_out "got $@"
		exit -1
	fi
	local lxd_host=$1
	local lxd_container=$2
	local target_command=$3
	echo sudo lxc exec ${lxd_host}:${lxd_container} -- bash -c "${target_command}"
	sudo lxc exec ${lxd_host}:${lxd_container} -- bash -c "${target_command}"
	command_result=$?
        if [ "${IGNORE_RESULTS}" -ne "0" ] && [ ${command_result} -ne 0 ] ; then
		echo_std_out "[lxd_destroy_container] Failed to create the container"
		echo_std_out echo ${source_str} | sudo lxc exec ${lxd_host}:${lxd_container} -- bash -c " tee -a ${target_file}"
		exit -1
	fi
}


