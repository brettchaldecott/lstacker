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
# A boot script wrapper
#

function boot_scripts_setup_lstacker {
	# validate import
	if [ "$#" -ne 1 ]; then
		echo_std_out "[boot_script_setup_lstacker]Illegal number of parameters"
		echo_std_out "arguments <host>"
		exit -1
	fi

	local host=$1
	local yaml_name_var_name="yml_lstack_servers_${host}_name"
	local yaml_name_var=${!yaml_name_var_name}
	if [ -z ${yaml_name_var} ] ; then
		echo_std_out "No name information for the server [${host}]"
		exit -1
	fi


	cli_execute_command "${yaml_name_var}" "sudo mkdir -p ${LSTACKER_STARTUP_DIR}"


	# create a startup script
	read -r -d '' boot_scripts_startup_file <<- EOF
	#!/bin/bash
	#
	# lstack generated start script
	#

	EOF

	cli_execute_command_with_input "${yaml_name_var}" "sudo tee -a ${LSTACKER_STARTUP_FILE}" "${boot_scripts_startup_file}"
	cli_execute_command "${yaml_name_var}" "sudo chmod a+x ${LSTACKER_STARTUP_FILE}"

	# create a shutdown script
	read -r -d '' boot_scripts_shutdown_file <<- EOF
	#!/bin/bash
	#
	# lstack generated stop script
	#

	EOF

	cli_execute_command_with_input "${yaml_name_var}" "sudo tee -a ${LSTACKER_SHUTDOWN_FILE}" "${boot_scripts_shutdown_file}"
	cli_execute_command "${yaml_name_var}" "sudo chmod a+x ${LSTACKER_SHUTDOWN_FILE}"


	# setup the startup commands
	cli_execute_command_with_file "${yaml_name_var}" "sudo tee ${LSTACKER_UBUNTU_INITD_SCRIPT}" "${LSTACKER_UBUNTU_START_TEMPLATE}"
	cli_execute_command "${yaml_name_var}" "sudo chmod a+x ${LSTACKER_UBUNTU_INITD_SCRIPT}"
	cli_execute_command "${yaml_name_var}" "sudo ln -s ${LSTACKER_UBUNTU_INITD_SCRIPT} /etc/rc2.d/S90lstacker"
	cli_execute_command "${yaml_name_var}" "sudo ln -s ${LSTACKER_UBUNTU_INITD_SCRIPT} /etc/rc3.d/S90lstacker"
	cli_execute_command "${yaml_name_var}" "sudo ln -s ${LSTACKER_UBUNTU_INITD_SCRIPT} /etc/rc4.d/S90lstacker"
	cli_execute_command "${yaml_name_var}" "sudo ln -s ${LSTACKER_UBUNTU_INITD_SCRIPT} /etc/rc5.d/S90lstacker"
	cli_execute_command "${yaml_name_var}" "sudo ln -s ${LSTACKER_UBUNTU_INITD_SCRIPT} /etc/rc0.d/K90lstacker"
	cli_execute_command "${yaml_name_var}" "sudo ln -s ${LSTACKER_UBUNTU_INITD_SCRIPT} /etc/rc1.d/K90lstacker"
	cli_execute_command "${yaml_name_var}" "sudo ln -s ${LSTACKER_UBUNTU_INITD_SCRIPT} /etc/rc6.d/K90lstacker"
}

function boot_scripts_clear_lstacker {
	# validate import
	if [ "$#" -ne 1 ]; then
		echo_std_out "[boot_scripts_clear_lstacker]Illegal number of parameters"
		echo_std_out "arguments <host>"
		exit -1
	fi

	local host=$1
	local yaml_name_var_name="yml_lstack_servers_${host}_name"
	local yaml_name_var=${!yaml_name_var_name}
	if [ -z ${yaml_name_var} ] ; then
		echo_std_out "No name information for the server [${host}]"
		exit -1
	fi

	# remove the startup commands
	cli_execute_command "${yaml_name_var}" "sudo rm -f /etc/rc2.d/S90lstacker"
	cli_execute_command "${yaml_name_var}" "sudo rm -f /etc/rc3.d/S90lstacker"
	cli_execute_command "${yaml_name_var}" "sudo rm -f /etc/rc4.d/S90lstacker"
	cli_execute_command "${yaml_name_var}" "sudo rm -f /etc/rc5.d/S90lstacker"
	cli_execute_command "${yaml_name_var}" "sudo rm -f /etc/rc0.d/K90lstacker"
	cli_execute_command "${yaml_name_var}" "sudo rm -f /etc/rc1.d/K90lstacker"
	cli_execute_command "${yaml_name_var}" "sudo rm -f /etc/rc6.d/K90lstacker"
	cli_execute_command "${yaml_name_var}" "sudo rm -f ${LSTACKER_UBUNTU_INITD_SCRIPT}"

	# remove the startup directory
	cli_execute_command "${yaml_name_var}" "rm -rf ${LSTACKER_STARTUP_DIR}"
}

function boot_scripts_add_start_command {
	# validate import
	if [ "$#" -ne 2 ]; then
		echo_std_out "[boot_scripts_add_start_command]Illegal number of parameters"
		echo_std_out "arguments <host> <command>"
		exit -1
	fi
	local host=$1
	local start_command="$2"
	local yaml_name_var=${host}
	if [ "${yaml_name_var}" != "local" ] ; then
		local yaml_name_var_name="yml_lstack_servers_${host}_name"
		yaml_name_var=${!yaml_name_var_name}
		if [ -z ${yaml_name_var} ] ; then
			echo_std_out "No name information for the server [${host}]"
			exit -1
		fi
	fi

	cli_execute_command_with_input "${yaml_name_var}" "sudo tee -a ${LSTACKER_STARTUP_FILE}" "${start_command}"

}

function boot_scripts_add_stop_command {
	# validate import
	if [ "$#" -ne 2 ]; then
		echo_std_out "[boot_scripts_add_stop_command]Illegal number of parameters"
		echo_std_out "arguments <host> <command>"
		exit -1
	fi
	local host=$1
	local stop_command="$2"
	local yaml_name_var=${host}
	if [ "${yaml_name_var}" != "local" ] ; then
		local yaml_name_var_name="yml_lstack_servers_${host}_name"
		yaml_name_var=${!yaml_name_var_name}
		if [ -z ${yaml_name_var} ] ; then
			echo_std_out "No name information for the server [${host}]"
			exit -1
		fi
	fi

	cli_execute_command_with_input "${yaml_name_var}" "sudo tee -a ${LSTACKER_STARTUP_FILE}" "${stop_command}"

}



# setup the network
function boot_scripts_setup_servers {
	echo_std_out "Setup boot scripts"

	local servers=${yml_lstack_servers_names[@]}
	if [ -z "${servers[@]}" ] ; then
		echo_std_out "Must provide the lstack_server_names configuration"
		exit -1
	fi

	# setup lxc profiles for networks
	for boot_script_setup_server_name in ${servers[@]} ; do
		echo "Setup the startup scripts on ${boot_script_setup_server_name}"
		boot_script_setup_lstacker ${boot_script_setup_server_name}
		echo "Finished setting up the startup scripts on  ${boot_script_setup_server_name}"
	done
	echo_std_out "Setup boot scripts"
}


# function to clear the networking
function boot_scripts_clear_servers {
	echo_std_out "Clear boot scripts from servers"

	# retrieve the yml server names that have to cleared
	local servers=${yml_lstack_servers_names[@]}
	if [ -z "${servers[@]}" ] ; then
		echo_std_out "Must provide the lstack_server_names configuration"
		exit -1
	fi

	# setup lxc profiles for networks
	for network_setup_server in ${servers[@]} ; do
		echo "Clear the startup scripts on ${boot_script_setup_server_name}"
		boot_script_clear_lstacker ${boot_script_setup_server_name}
		echo "Finished clearing th startup scripts on  ${boot_script_setup_server_name}"
	done
	echo_std_out "Cleared boot scripts from servers"
}


