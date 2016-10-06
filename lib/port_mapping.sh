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
# This file is responsible for managing the port mappings
#

# setup the port mapping for a host and port
function port_mapping_map_ports_for_host_and_port {
	# validate import
	if [ "$#" -ne 2 ]; then
		echo_std_out "[port_mapping_map_ports_for_host_and_port] Illegal number of parameters"
		echo_std_out "arguments <host> <port>"
		echo_std_out "Got $@"
		exit -1
	fi
	local host=$1
	local port=$2

	eval "declare -a port_mapping_container=(`get_yaml_config_var "${host}" "${port}" container`)"
	eval "declare -a port_mapping_target_port=(`get_yaml_config_var "${host}" "${port}" target_port`)"
	eval "declare -a port_mapping_source_port=(`get_yaml_config_var "${host}" "${port}" source_port`)"
	eval "declare -a port_mapping_source_dev=(`get_yaml_config_var "${host}" "${port}" source_dev`)"
	eval "declare -a port_mapping_lxd_server=(`get_yaml_config_var servers ${host} name`)"
	if [ -z "${port_mapping_container[@]}" ] || [ -z "${port_mapping_target_port[@]}" ] || [ -z "${port_mapping_source_port[@]}" ] || [ -z "${port_mapping_source_dev[@]}" ] ; then
		echo_std_out "[port_mapping_map_ports_for_host_and_port] incorrect port mapping for ${host}:${port}"
		echo_std_out "must provide [container][target_port][source_port] for port mappin"
		echo_std_out "Got [${port_mapping_container[@]}][${port_mapping_target_port[@]}][${port_mapping_source_port[@]}][${port_mapping_source_dev[@]}]"
		return 1
	fi

	# retrieve the target ip for the port mapping
	local target_ip=`cli_execute_command ${port_mapping_lxd_server} "lxc list ${port_mapping_container[0]} -c 4 \| grep eth0 \| cut -d ' ' -f 2"`
	local target_ip_result=$?
	if [ ! ${target_ip_result} ] ; then
		echo_std_out "[port_mapping_map_ports_for_host_and_port] failed to retrieve the target ip"
		echo_std_out "Query on server ${port_mapping_lxd_server}:${port_mapping_container[0]}"
		echo_std_out "Got ${target_ip}"
		return ${target_ip_result}
	fi

	# setup the port forwarding
	local port_forward_result=`cli_execute_command ${port_mapping_lxd_server} "sudo iptables -t nat -A PREROUTING -i ${port_mapping_source_dev[0]} -p tcp --dport ${port_mapping_source_port[0]} -j DNAT --to ${target_ip}:${port_mapping_target_port}"`
	local port_forward_result_no=$?
	if [ ! ${port_forward_result_no} ] ; then
		echo_std_out "[port_mapping_map_ports_for_host_and_port] failed to map the ports"
		echo_std_out "Query on server ${host}:${port_mapping_container[0]}:${port_mapping_source_port[0]}"
		echo_std_out "Got ${port_forward_result}"
		return ${target_ip_result}

	fi
}

# clear the port mapping for a host and port
function port_mapping_clear_ports_for_host_and_port {
	# validate import
	if [ "$#" -ne 2 ]; then
		echo_std_out "[port_mapping_clear_ports_for_host_and_port] Illegal number of parameters"
		echo_std_out "arguments <host> <port>"
		echo_std_out "Got $@"
		exit -1
	fi
	local host=$1
	local port=$2

	eval "declare -a port_mapping_source_port=(`get_yaml_config_var "${host}" "${port}" source_port`)"
	eval "declare -a port_mapping_lxd_server=(`get_yaml_config_var servers ${host} name`)"
	if [ -z "${port_mapping_source_port[@]}" ] ; then
		echo_std_out "[port_mapping_clear_ports_for_host_and_port] incorrect port mapping for ${host}:${port}"
		echo_std_out "must provide [source_port] for port mapping"
		echo_std_out "Got [${port_mapping_source_port[@]}]"
		return 1
	fi

	# retrieve the line numbers
	local rule_line_numbers=(`cli_execute_command ${port_mapping_lxd_server} "sudo iptables -t nat --line-numbers -L \| grep DNAT \| grep ${port_mapping_source_port[0]} | cut -d ' ' -f 1"`)
	local rule_line_number_result=$?
	if [ ! ${rule_line_number_result} ] ; then
		echo_std_out "[port_mapping_map_ports_for_host_and_port] failed to retrieve the target ip"
		echo_std_out "Query on server ${host}:${port_mapping_container[0]}"
		echo_std_out "Got ${rule_line_numbers}"
		return ${rule_line_number_result}
	fi
	echo "The rule_line_numbers: ${rule_line_numbers}"
	for port_mapping_rule_line_number in ${rule_line_numbers[@]} ; do
		# setup the port forwarding
		local clear_port_forward_result=`cli_execute_command ${port_mapping_lxd_server} "sudo iptables -t nat -D PREROUTING ${port_mapping_rule_line_number}"`
		local clear_port_forward_result_no=$?
		if [ ! ${clear_port_forward_result_no} ] ; then
			echo_std_out "[port_mapping_clear_ports_for_host_and_port] failed to clear the port"
			echo_std_out "Query on server ${host}:${port_mapping_source_port[0]}"
			echo_std_out "Got ${clear_port_forward_result}"
		fi
	done


}

# this function is called to map ports
function port_mapping_map_ports_for_host {
	# validate import
	if [ "$#" -ne 1 ]; then
		echo_std_out "[port_mapping_map_ports_for_host] Illegal number of parameters"
		echo_std_out "arguments <host>"
		echo_std_out "Got $@"
		exit -1
	fi

	local host=$1
	echo "Port mapping for ${host}"
	eval "declare -a port_mapping_map_ports=(`get_yaml_config_var "${host}" ports`)"
	for port_mapping_map_port in ${port_mapping_map_ports[@]:-} ; do
		port_mapping_map_ports_for_host_and_port ${host} ${port_mapping_map_port}
	done
}

# this function is called to map ports
function port_mapping_clear_ports_for_host {
	# validate import
	if [ "$#" -ne 1 ]; then
		echo_std_out "[port_mapping_clear_ports_for_host] Illegal number of parameters"
		echo_std_out "arguments <host>"
		echo_std_out "Got $@"
		exit -1
	fi

	local host=$1
	echo "Clear port mapping for ${host}"
	eval "declare -a port_mapping_clear_ports=(`get_yaml_config_var "${host}" ports`)"
	for port_mapping_clear_port in ${port_mapping_clear_ports[@]:-} ; do
		port_mapping_clear_ports_for_host_and_port ${host} ${port_mapping_clear_port}
	done
}

#
# port mapping map ports
function port_mapping_map_ports {
	echo_std_out "Map ports"
	local hosts_array=${yml_lstack_servers_names[@]}
	for port_mapping_lxd_host in ${hosts_array[@]} ; do
		echo "Map the ports on ${hosts_lxd_host}"
		port_mapping_map_ports_for_host "${port_mapping_lxd_host}"
	done
	echo_std_out "Ports mapped"
}

#
# port mapping map ports
function port_mapping_clear_ports {
	echo_std_out "Clear ports"
	local hosts_array=${yml_lstack_servers_names[@]}
	for port_mapping_lxd_host in ${hosts_array[@]} ; do
		echo "Map the ports on ${port_mapping_lxd_host}"
		port_mapping_clear_ports_for_host "${port_mapping_lxd_host}"
	done
	echo_std_out "Ports mapped"
}

