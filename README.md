# LStacker

The LStacker project is a network and infrastructure builder. It builds a container based network on top of the infrastructure supplied to it. Using this approach enables an organisation to quickly build infrastructure on minimul hardware, in and out of the cloud. Thus maximizing investement.

## Approach
LStacker is designed to use a simple build approach to infrastructure setup as detailed below:

* A simple Yaml configuration file is used to define the network and server infrastructure that will be built.
* Infrasture is built on top of simple vanilla VM's or Cloud instances. And can easily be rebuilt at any stage. [Ubuntu](http://www.ubuntu.com/) 16.04 is a requirement at present.
* [LXD](https://linuxcontainers.org/lxd/) is used to build out the server container infrastucture.
* [Docker](https://www.docker.com/) is fully supported and docker swarm can be used to bring up complex applications.
* A virtual network using a GRE/VxLAN bridge enables all containers to communicate with each other across the infrastructure. Be they on one or multiple servers. Openvswitch is used to manage this network.
* The virtual network is normally divided into the following components:
    * Management network: This network is setup to enable the management processes to communicate with the containers. This will be used by monitoring processes such as check_mk, or by the dns server.
    * Test network: This network is used for test purposes. If you want to play around with technology use this network.
    * Development network: This is used for development purposes.
    * QA network: A network for QA purposes
    * Production network: A network for production purposes.
* A jump-box is built as a means to access the virtual network. Use [sshuttle](http://sshuttle.readthedocs.io/) to setup a VPN like connection into the jump-box and then access all the virtual infrastructure as if you were on the network. Multiple jump-boxes can be built if horizontal loading within the network is a requirement.
* Production instances can be exposed through the jump-box by configuring port mappings and haproxy.
* Recipes are used to build the containers and custom recipies can easily be written and executed. This means server infrastructure can be built to match your requirements.
* A base set of recipies are supplied; they include jenkins, mysql, postgres, apache, haproxy, salt, omd etc.

## Infrastructure
I recommend running on a minum of 4 either virtual machines or cloud instances. These you can allocate as you see fit in your Lstacker build file. If you are worried about the costs then use micro instances on EC2 will work, but more may have to be allocated. This will not cause a problem with the build process. If cost is not a factor than I recommend a medium instance or higher.

1. Install vanilla version of [Ubuntu](http://www.ubuntu.com/download/server) 16.04 onto the target virtual machines or cloud instances.
2. Ear mark a virtual machine or instance as the master server and setup ssh key based access from it to the other instances.
3. Clone this project and add it to the PATH environment variable on the master server.

## System setup
Each VM or cloud instance needs to be updated as follows.
```
sudo apt update
sudo apt upgrade -y
sudo apt install lxd openvswitch-switch -y
sudo reboot
```

## Hostname configuration
Make sure the hosts names are configured correctly. This is not a requirement but will reduce the amount of warnings that will come to the console. To do this follow these steps:

1. Edit the host name file with your editor of choice for example `sudo vi /etc/hostname`. Set the hostname to 
2. Edit the hosts file and add the hostname of choice to the loop back ip entra. `sudo vi /etc/hosts` 
3. Set the hostname for the running instance by running the host command. `sudo hostname <host name>`

## LXD Setup
LXD/LXC has to be configured appropriatly. This requires running the `lxd init` command. This has to be peformed on all boxes. Select the configuration that makes the most sense for your environment. I recommend running on a ZFS pool, if this is not available than a standard dir backend will work fine.

## Openvswitch
Openvswitch has to be installed on all hosts. This can be done through apt as follows:

```sudo apt install openvswitch-switch```

## Build Process

1. Setup a lstacker context directory.
2. Write a `lstacker.yaml` file defining the network and infrastructure. There are example provided with this project.
3. Build the infrastructure
   `lstacker stack`

## Example steps
An example of what needs to be one to use LStacker correctly.

```
git clone https://github.com/brettchaldecott/lstacker.git
PATH=$PATH:`pwd`/lstacker
export PATH
mkdir lstacker-context
cd lstacker-context
cp ../lstacker/examples/ec2-small-lstacker.yml lstacker.yml
vi lstacker.yaml
# Edit the file to match your build requirements
.
.
# put the private key refered to in the lstacker.yaml file in the lstacker-context directory
cp "private key"
.
# build a public key file containing all the keys you wish to access the infrastructure
# it is also refered to in the lstacker.yml file
.
# run the lstacker command
lstacker stack
```

To clean up simply run the unstack command
```
lstacker unstack
```

## Access the network
Once a network has been built it can be access by sshing directly to the jump-box or more efficently by using [sshuttle](http://sshuttle.readthedocs.io/).

To ssh directly to the jump box use the following command:
```
ssh -i private_key_file -p 10022 ubuntu@hostname_or_ip_of_master
```

To setup and use sshuttle use the following command
```
sshuttle -r ubuntu@hostname_or_ip_of_master 10.0.0.0/8 -e "ssh -p 10022 -i key_file"
```

Once the sshuttle connection is established you will be able to ssh directly to any of the severs in the network you have built. For ip address or hostname information refer to the hosts file directory within the lstacker-context directory. This contains the hostnames and ip addresses for all servers built within the infrastructure.

