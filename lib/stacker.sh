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
# This is the master stack process
#


# this function is responsible for building a stack
function stacker_build_stack {
	echo_std_out "Build a stack"
	
	# setp the network
	network_setup_network

	# setup the profiles
	lxd_profile_create_network_profiles

	# create all the containers
	container_create_containers

	# set the hosts on the network
	hosts_set_hosts

	# setup the port forwarding
	port_mapping_map_ports

	# set the hosts information per network
	echo_std_out "Finished building stack"
}


# this function is responsible for clearing up a stack
function stacker_clear_stack {
	echo "Clear a stack"

	# clear the port mapping
	port_mapping_clear_ports

	# clear all the containers
	container_destroy_containers

	# clear the network pfofiles
	lxd_profile_clear_network_profiles

	# clear the bridge network
	network_clear_network

	echo "Finished clearing the stack"

}
