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


# Execute the command being passed in
function execute_command {
	echo_std_out "command ${lstacker_command}"
	# check the command and execute
	case "${lstacker_command}" in
		help)
			echo_commands
			exit -1
			;;
		version)
			echo_std_out "Version: ${LSTACKER_VERSION}"
			exit -1
			;;
		stack)
			stack
			;;
		unstack)
			unstack
			;;
		create)
			create
			;;
		destroy)
			destroy
			;;

		*)
			echo_std_out "Invalid command"
			echo_commands
			exit -1
			;;
	esac

}


#
# build a full network stack
function stack {
	read_config_file ${lstacker_file}
	echo_std_out "Build Stack"
	stacker_build_stack
	echo_std_out "Finished stacking"
}

#
# remove a full network stack
function unstack {
	read_config_file ${lstacker_file}
	echo_std_out "Cleanup Stack"
	stacker_clear_stack
	echo_std_out "Finished unstack"

}

# this function is called to create a new container
function create {
	if [ -z "${lstacker_host}" ] ; then
		echo_std_out "Invalid command"
		echo_commands
		exit -1
	fi
	if [ -z "${lstacker_container}" ] ; then
		echo_std_out "Invalid command"
		echo_commands
		exit -1
	fi
	read_config_file ${lstacker_file}
	echo_std_out "Create container <${lstacker_host}>:<${lstacker_container}>"
	container_create_container ${lstacker_host} ${lstacker_container}
}

# this function is responsible for destorying a container
function destroy {
	if [ -z "${lstacker_host}" ] ; then
		echo_std_out "Invalid command"
		echo_commands
		exit -1
	fi
	if [ -z "${lstacker_container}" ] ; then
		echo_std_out "Invalid command"
		echo_commands
		exit -1
	fi
	read_config_file ${lstacker_file}
	echo_std_out "Destroy container <${lstacker_host}>:<${lstacker_container}>"
	container_destroy_container ${lstacker_host} ${lstacker_container}
	
}
