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

# This function is called to apply a recipy to a specific
# container
function apply_recipe_file {

	if [ "$#" -ne 3 ]; then
		echo_std_out "Illegal number of parameters"
		echo_std_out "arguments <file> <lxd_host> <lxd_container>"
		exit -1
	fi
	local recipe_file=$1
	local lxd_host=$2
	local lxd_container=$3
	local ignore_error=${IGNORE_RESULTS}
	IGNORE_RESULTS=0

	while read line; do    
		echo "Line is ${line}"
		if [[ -z "${line// }" ]] ; then
			continue
		fi
		if [[ ${line:0:1} == '#' ]] ; then
			continue
		fi
		local parsedLine=`eval echo "${line}"`
		echo "Line is ${parsedLine}"
		local executeResult=`eval lxd_execute_command ${lxd_host} ${lxd_container} "${parsedLine}"`
		echo "After executing ${executeResult}"
	done < ${recipe_file};
	IGNORE_RESULTS=${ignore_error}
}

# apply a recipe to a box
function apply_recipe {

	if [ "$#" -ne 5 ]; then
		echo_std_out "[apply_recipe]Illegal number of parameters"
		echo_std_out "arguments <linux> <linux_version> <lxd_host> <lxd_container> <recipe>"
		echo_std_out "Got $# arguments $@"
		exit -1
	fi
	local linux=$1
	local linux_version=$2
	local lxd_host=$3
	local lxd_container=$4
	local recipe=$5

	# apply the recipe from local context
	local context_base=${LSTACKER_CONTEXT}
	local recipe_file="${context_base}/${recipe}"
	echo "Check for a recipe ${recipe_file}"
	if [ -f ${recipe_file} ]; then
		apply_recipe_file ${recipe_file} ${lxd_host} ${lxd_container}
		return 0
	fi

	# use recipies from installation
	local base_path=${LS_BASE_DIR}

	recipe_file="${base_path}/recipes/${linux}/${recipe}"
	echo "Check for a recipe ${recipe_file}"
	if [ -f ${recipe_file} ] ; then
		apply_recipe_file ${recipe_file} ${lxd_host} ${lxd_container}
		return 0
	fi
	recipe_file="${base_path}/recipes/${linux}/${linux_version}/${recipe}"
	echo "Check for a recipe ${recipe_file}"
	if [ -f ${recipe_file} ] ; then
		apply_recipe_file ${recipe_file} ${lxd_host} ${lxd_container}
		return 0
	fi

	echo "Failed to find the recipe ${recipe}"
	echo_std_out "Failed to find the recipe ${recipe}"
	exit -1
}

