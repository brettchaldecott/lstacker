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


# Add an eth device to a container
function add_eth {
	if [ "$#" -ne 6 ]; then
		echo_std_out "[add_eth] Illegal number of parameters"
		echo_std_out "arguments <linux> <lxd_host> <lxd_container> <device> <address> <network>"
		echo_std_out "got $@"
		exit -1
	fi
	local linux=$1
	local lxd_host=$2
	local lxd_container=$3
	local device=$4
	local address=$5
	local network=$6

	if [ ${linux} == ubuntu ]; then
		debian_eth_config ${lxd_host} ${lxd_container} ${device} ${address} ${network}
		debian_eth_up ${lxd_host} ${lxd_container} ${device}
	elif [ ${linux} == centos ]; then
		centos_eth_config ${lxd_host} ${lxd_container} ${device} ${address} ${network}
		centos_eth_up ${lxd_host} ${lxd_container} ${device}
	fi
}


###############################################################################
# debian specific methods
###############################################################################

# ubuntu setup the eth interface
function debian_eth_config {
	if [ "$#" -ne 5 ]; then
		echo_std_out "[debian_eth_config] Illegal number of parameters"
		echo_std_out "arguments <lxd_host> <lxd_container> <device> <address> <network>"
		exit -1
	fi
	local lxd_host=$1
	local lxd_container=$2
	local device=$3
	local address=$4
	local network=$5

	read -r -d '' ethConf <<- EOF
        # begin of network device ${device}
	# ${ADD_BY_MESSAGE}
	auto ${device}
	iface ${device} inet static
	    address ${address}
	    network ${network}.0.0
	    netmask 255.255.0.0
	    gateway ${network}.0.1
	    mtu 1400
	# end of network interface ${device}
	EOF
	
	lxd_string_to_file_append ${lxd_host} ${lxd_container} "${ethConf}" /etc/network/interfaces
}

function debian_eth_up {
	if [ "$#" -ne 3 ]; then
		echo_std_out "[debian_eth_up] Illegal number of parameters"
		echo_std_out "arguments <lxd_host> <lxd_container> <device>"
		exit -1
	fi

	local lxd_host=$1
	local lxd_container=$2
	local device=$3
	lxd_execute_command ${lxd_host} ${lxd_container} "ifdown ${device}"
	lxd_execute_command ${lxd_host} ${lxd_container} "ifup ${device}"

}

###############################################################################
# centos specific methods
###############################################################################

# centos setup the eth interface
function centos_eth_config {
	if [ "$#" -ne 5 ]; then
		echo_std_out "[centos_eth_config] Illegal number of parameters"
		echo_std_out "arguments <lxd_host> <lxd_container> <device> <address> <network>"
		exit -1
	fi
	local lxd_host=$1
	local lxd_container=$2
	local device=$3
	local address=$4
	local network=$5

	read -r -d '' ethConf <<- EOF
        # begin of network device ${device}
	# ${ADD_BY_MESSAGE}
	DEVICE=${device}
	BOOTPROTO=none 
	ONBOOT=yes 
	NETWORK=${network}.0.0
	NETMASK=255.255.0.0 
	IPADDR=${address}
	GATEWAY=${network}.0.1
	USERCTL=no
	MTU=1400
	EOF
	
	lxd_string_to_file ${lxd_host} ${lxd_container} "${ethConf}" /etc/sysconfig/network-scripts/ifcfg-${device}
}

# centos eth up
function centos_eth_up {
	if [ "$#" -ne 3 ]; then
		echo_std_out "[centos_eth_up] Illegal number of parameters"
		echo_std_out "arguments <lxd_host> <lxd_container> <device>"
		echo_std_out "got $@"
		exit -1
	fi

	local lxd_host=$1
	local lxd_container=$2
	local device=$3
	lxd_execute_command ${lxd_host} ${lxd_container} "ifdown ${device}"
	lxd_execute_command ${lxd_host} ${lxd_container} "ifup ${device}"

}

