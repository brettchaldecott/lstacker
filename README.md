# LStacker

The LStacker project is a virtual infrastructure builder. It builds a virtual container based network on top of the infrastructure supplied to it. Using this approach enables an organisation to quickly build its infrastructure on minimul hardware, in and out of the cloud. Thus maximizing investement.

## Update
The container creation and destroy commands have now been tested and work correctly, I am now testing the network an profile creation processes. When this process is complete iwill be possible to stack an entire network matching your requirements.

## Approach
LStacker is designed to use a simple build and deploy process and provides the following:

* A simple Yaml configuration file is used to define the network and server infrastructure.
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
* A jump-box is built as a means to access the virtual network. Use [sshuttle](http://sshuttle.readthedocs.io/) to setup a VPN like connection into the jump-box and then access all the virtual infrastructure as if you were on the network. Multiple can be built if horizontal loading within the network is a requirement.
* At present production instances can be exposed by port mapping onto a reverse proxy like haproxy. This is a recommended service for the jump box.

## Instastructure
I recommend running on a minum of 4 either virtual machines or cloud instances. These you can allocate as you see fit in your Lstacker build file. If you are worried about the costs then use micro instances on EC2(They are free), you will just have to allocate more of them. This will not cause a problem with the build process. If cost is not a factor than I recommend a medium instance or higher as they 

1. Install vanilla version of [Ubuntu](http://www.ubuntu.com/download/server) 16.04 onto the target virtual machines or cloud instances.
2. Ear mark a virtual machine or instance as the master server and setup ssh access from it to the other instances.
3. Clone this project and add it to the PATH environment variable on the master server.

## LXD Setup
LXD/LXC has to be configured appropriatly.

1. Init LXD using the `lxd init` command. This has to be peformed on all boxes. Select the configuration that makes the most sense for your environment. I recommend running on a ZFS pool, if this is not available than a standard dir backend will work fine.
2. The management port has to be exposed and the trust password set on all lxd instances.

    sudo lxc config set core.https_address [::]
    sudo lxc config set core.trust_password some-password

3. All LXD servers have to know about each other. This requires they are registered as remotes with each other.
   `sudo lxc remote add lxd1 <ip address or DNS of remote service>`


## Openvswitch
Openvswitch has to be installed on all hosts. This can be done through apt as follows:
   `sudo apt install openvswitch-switch`

## Build Process

1. Setup a lstacker context directory.
2. Write a `lstacker.yaml` file defining the network and infrastructure. There are example provided with this project.
3. Build the infrastructure
   `lstacker stack`
