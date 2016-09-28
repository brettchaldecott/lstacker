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
# setup the proxy for a particular unix system
function configure_proxy {
	if [ "$#" -ne 6 ]; then
		echo_std_out "Illegal number of parameters"
		echo_std_out "arguments <linux> <linux_version> <lxd_host> <lxd_container> <proxy> <proxy_https>"
		exit -1
	fi
	local linux=$1
	local linux_version=$2
	local lxd_host=$3
	local lxd_container=$4
	local proxy=$5
	local proxy_https=$6


	if [ ${linux} == ubuntu ]; then
		debian_configure_proxy ${linux_version} ${lxd_host} ${lxd_container} ${proxy} ${proxy_https}
	elif [ ${linux} == centos ]; then
		centos_configure_proxy ${linux_version} ${lxd_host} ${lxd_container} ${proxy} ${proxy_https}
	fi
}


function debian_configure_proxy {
	if [ "$#" -ne 5 ]; then
		echo_std_out "Illegal number of parameters"
		echo_std_out "arguments <linux_version> <lxd_host> <lxd_container> <proxy> <proxy_https>"
		exit -1
	fi
	local linux_version=$1
	local lxd_host=$2
	local lxd_container=$3
	local proxy=$4
	local proxy_https=$5


	read -r -d '' envProxy <<- EOF
	http_proxy=${proxy}
	https_proxy=${proxy_https}
	HTTP_PROXY=${proxy}
	HTTPS_PROXY=${proxy_https}
	EOF

	lxd_string_to_file_append ${lxd_host} ${lxd_container} "${envProxy}" /etc/network/interfaces

	# apt on ubuntu 14.04 does not work without this change
	if [ "${linux_version}" -eq "14.04" ] ; then 

		read -r -d '' envProxy <<- EOF
		Acquire::http::proxy "${proxy}";
		Acquire::https::proxy "${proxy_https}";
		EOF

		lxd_string_to_file ${lxd_host} ${lxd_container} "${envProxy}" /etc/apt/apt.conf.d/95proxy

	fi

}

function centos_configure_proxy {
	if [ "$#" -ne 5 ]; then
		echo_std_out "Illegal number of parameters"
		echo_std_out "arguments <lxc_version> <lxd_host> <lxd_container> <proxy> <proxy_https>"
		exit -1
	fi
	local linux_version=$1
	local lxd_host=$2
	local lxd_container=$3
	local proxy=$4
	local proxy_https=$5

	read -r -d '' envProxy <<- EOF

	# proxy configuration
	http_proxy=${proxy}
	https_proxy=${proxy_https}
	HTTP_PROXY=${proxy}
	HTTPS_PROXY=${proxy_https}
	export http_proxy https_proxy HTTP_PROXY HTTPS_PROXY
	# end of proxy configuration

	EOF

	lxd_string_to_file_append ${lxd_host} ${lxd_container} "${envProxy}" /etc/profile

}
