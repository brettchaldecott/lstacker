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
# This openvswitch wrapper
#

# create the bridge
function openvswitch_create_bridge {
	# validate import
	if [ "$#" -ne 2 ]; then
		echo_std_out "Illegal number of parameters"
		echo_std_out "arguments <host> <remote_ips>"
		exit -1
	fi

	local host=$1
	declare -a openvswitch_ip_array=("${!2}")

	cli_execute_command "${host}" "sudo ovs-vsctl --may-exist add-br ${BRIDGE_NAME}"
	local eth_dev_count=0
	for openvswitch_ip in ${openvswitch_ip_array[@]} ; do
		cli_execute_command "${host}" "sudo ovs-vsctl --may-exist add-port ${BRIDGE_NAME} gre-${eth_dev_count} -- set interface gre-${eth_dev_count} type=gre options:remote_ip=${openvswitch_ip}"
		boot_scripts_add_start_command "${host}" "sudo ovs-vsctl --may-exist add-port ${BRIDGE_NAME} gre-${eth_dev_count} -- set interface gre-${eth_dev_count} type=gre options:remote_ip=${openvswitch_ip}"
		boot_scripts_add_stop_command "${host}" "sudo ovs-vsctl --if-exist del-port ${BRIDGE_NAME} gre-${eth_dev_count}"

		((++eth_dev_count))
	done
	# enable spanning tree. this is critical
	cli_execute_command "${host}" "sudo ovs-vsctl set bridge ${BRIDGE_NAME} stp_enable=true"

}


# destroy a bridge
function openvswitch_destroy_bridge {
	# validate import
	if [ "$#" -ne 1 ]; then
		echo_std_out "Illegal number of parameters"
		echo_std_out "arguments <host>"
		exit -1
	fi

	local host=$1

	cli_execute_command "${host}" "sudo ovs-vsctl --if-exist del-br ${BRIDGE_NAME}"

}


