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
# The generic monitoring setup
#

# import the alternativer monitoring implementations
. ${LS_BASE_DIR}/lib/omd_setup.sh

function monitoring_scripts_setup_monitoring {
	if [ -z "${yml_lstack_monitoring_type:-}" ] ; then
		echo_log "There is no monitoring"
		return 0
	fi
	local monitor_type=${yml_lstack_monitoring_type[0]}

	if [ "${monitor_type}" == "omd" ] ; then
		omd_setup_setup_monitoring "${host}" "${container}" "${network}"
	fi

}

# clear the monitoring
function monitoring_scripts_clear_monitoring {
	if [ -z "${yml_monitoring_type}" ] ; then
		echo_log "There is no monitoring"
		return 0
	fi
	local monitor_type=${yml_monitoring_type[0]}

	if [ "${monitor_type}" == "omd" ] ; then
		omd_setup_clear_monitoring
	fi
}

