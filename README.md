# LStacker - Alpha state not all things mentioned below are complete or tested

The LStacker project is a virtual infrastructure builder. It builds a virtual container based network on top of the infrastructure supplied to it. Using this approach enables an organisation to quickly build its infrastructure on minimul hardware, in and out of the cloud. Thus maximizing investement.

## Approach
LStacker is designed to use a simple build and deploy process and provides the following:

* A simple Yaml configuration file is used to define the network and server infrastructure.
* Infrasture is built on top of simple vanilla VM's or Cloud instances. And can easily be rebuilt at any stage. [Ubuntu](http://www.ubuntu.com/) 16.04 is a requirement at present.
* [LXD](https://linuxcontainers.org/lxd/) is used to build out the server container infrastucture.
* [Docker](https://www.docker.com/) is fully supported and docker swarm can be used to bring up complex applications.
* A virtual network using a GRE/VxLAN bridge enables all containers to communicate with each other across the infrastructure. Be they on one or multiple servers. Openvswitch is used to manage this network.
* The virtual network is normally devided into the following components:
    * Management network: This network is setup to enable the management processes to communicate with the containers. This will be used by thinkgs like check_mk to monitor processes or by the dns server.
    * Test network: This network is used for test purposes. If you want to play around with technology use this network.
    * Development network: This is used for development purposes.
    * QA network: A network for QA purposes
    * Production network: A network for production purposes.
* A jump-box is built as a means to access the virtual network. Use [sshuttle](http://sshuttle.readthedocs.io/) to setup a VPN like connection into the jump-box and then access all the virtual infrastructure as if you were on the network.
* At present production instances can be exposed by port mapping onto a reverse proxy like haproxy.

## Instastructure

1. Install vanilla version of [Ubuntu](http://www.ubuntu.com/download/server) 16.04 onto the target virtual machines or cloud instances. I recommend a medium instance on EC2 or something equivalent.
2. Ear mark a virtual machine or instance as the master server and setup ssh access from it to the other instances.
3. Clone this project and add it to the PATH environment variable on the master server.


## Build Process

1. Setup a lstacker context directory.
2. Write a `lstacker.yaml` file defining the network and infrastructure. There are example provided with this project.
3. Build the infrastructure
   `lstacker stack`
