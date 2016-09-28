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



function echo_commands {
	echo_std_out 'Usage:'
	echo_std_out 'lstacker [OPTIONS] COMMAND [arg...]'
	echo_std_out 'lstacker [OPTIONS] create <host> <container> [arg...]'
	echo_std_out 'lstacker [OPTIONS] destroy <host> <container> [arg...]'
	echo_std_out ''
	echo_std_out 'Options:'
	echo_std_out '[-f,--file]    the path to file'
	echo_std_out ''
	echo_std_out 'Commands:'
	echo_std_out '[stack] default stack out the infrastructure'
	echo_std_out '[unstack] unstack a the infrastructure'
	echo_std_out '[help] help information'
	echo_std_out '[version] version information'
	echo_std_out '[create] create a new container'
	echo_std_out '[destroy] destory a container'
	echo_std_out ''

}
