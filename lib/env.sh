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

# force lstacker to exit if it uses variables that dont exist
set -u

# imports
. ${LS_BASE_DIR}/lib/logging.sh
. ${LS_BASE_DIR}/lib/config.sh
. ${LS_BASE_DIR}/lib/lxd_wrapper.sh
. ${LS_BASE_DIR}/lib/eth.sh
. ${LS_BASE_DIR}/lib/proxy.sh
. ${LS_BASE_DIR}/lib/recipe.sh
. ${LS_BASE_DIR}/lib/arguments.sh
. ${LS_BASE_DIR}/lib/command.sh
. ${LS_BASE_DIR}/lib/parse_yaml.sh
. ${LS_BASE_DIR}/lib/container.sh
. ${LS_BASE_DIR}/lib/ssh_key.sh
. ${LS_BASE_DIR}/lib/hosts.sh
. ${LS_BASE_DIR}/lib/stacker.sh
. ${LS_BASE_DIR}/lib/ssh_wrapper.sh
. ${LS_BASE_DIR}/lib/cli_wrapper.sh
. ${LS_BASE_DIR}/lib/network.sh
. ${LS_BASE_DIR}/lib/openvswitch.sh
. ${LS_BASE_DIR}/lib/lxd_config.sh
. ${LS_BASE_DIR}/lib/lxd_profile.sh
. ${LS_BASE_DIR}/lib/port_mapping.sh

