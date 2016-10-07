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
# Programmatic configuration


LSTACKER_VERSION=0.0.1
ETH_PROFILE_NAME="lstacker_eth"
BRIDGE_NAME="br-ls-gre0"
IGNORE_RESULTS=1
LSTACKER_CONTEXT=`pwd`
ADD_BY_MESSAGE="Added by Lstacker"
CONTAINER_WAIT_DELAY=5
HOSTS_DIRECTORY="${LSTACKER_CONTEXT}/hosts"

# setting the mtu size smaller than the tradition 1500
# in order to prevent packet fragmentation as GRE and VxLAN networks
# add headers to each packet.
ETH_MTU_SIZE=1400

# determine the lxd source
declare -A DISTRO_DEFAULT_HOME
DISTRO_DEFAULT_HOME["ubuntu"]="/home/ubuntu"
DISTRO_DEFAULT_HOME["centos"]="/root"

# determine the lxd source
declare -A LXD_SOURCE
LXD_SOURCE["ubuntu_16.04"]="ubuntu-daily"
LXD_SOURCE["ubuntu_14.04"]="ubuntu"
LXD_SOURCE["centos_7"]="images"
LXD_SOURCE["centos_6.5"]="images"

function get_lxd_source {
	if [ "$#" -ne 3 ]; then
		echo "$0 Illegal number of parameters" >&3
		echo "arguments <return_var> <linux> <linux_version>" >&3
		exit -1
	fi

	local return_result=$1
	local linux=$2
	local linux_version=$3

	eval ${return_result}=${LXD_SOURCE["${linux}_${linux_version}"]}
}


# determin the lxd image
declare -A LXD_IMAGE
LXD_IMAGE["ubuntu_16.04"]="16.04"
LXD_IMAGE["ubuntu_14.04"]="14.04"
LXD_IMAGE["centos_7"]="centos/7/amd64"
LXD_IMAGE["centos_6.5"]="centos/6/amd64"

function get_lxd_image {
	if [ "$#" -ne 3 ]; then
		echo "$0 Illegal number of parameters" >&3
		echo "arguments <return_var> <linux> <linux_version>" >&3
		exit -1
	fi

	local return_result=$1
	local linux=$2
	local linux_version=$3

	eval ${return_result}=${LXD_IMAGE["${linux}_${linux_version}"]}
}

# the configuration file
function read_config_file {
	if [ "$#" -ne 1 ]; then
		echo "Illegal number of parameters" >&3
		echo "arguments <linux> <linux_version>" >&3
		exit -1
	fi
	yml_file=$1
	parse_yaml ${lstacker_file} yml_
	eval $(parse_yaml ${lstacker_file} yml_)
}

# get yaml configuration
function get_yaml_config_var {
	if [ "$#" -lt "1" ] ; then
		echo_std_out "Illegal number of parameters" >&3
		echo_std_out "arguments <return_var> <config.....>" >&3
		exit -1
	fi
	local config="yml_lstack"
	for key in "$@" ; do
		config="${config}_${key}"
	done
	config=${config}[@]
	declare -a yamlArray=("${!config:-}")
	if [ -z ${yamlArray} ] ; then
		echo_std_out "Failed to retrieve the configuration value ${config}=${yamlArray[@]}"
		exit 1
	fi 
	echo "${yamlArray[@]}"
	return 0
}

# has yaml configuration
function has_yaml_config_var {
	if [ "$#" -lt "1" ] ; then
		echo_std_out "Illegal number of parameters" >&3
		echo_std_out "arguments <return_var> <config.....>" >&3
		exit -1
	fi
	local config="yml_lstack"
	for key in "$@" ; do
		config="${config}_${key}"
	done
	config=${config}[@]
	declare -a yamlArray=("${!config:-}")
	if [ -z "${yamlArray}" ] ; then
		return 1
	fi 
	return 0
}
