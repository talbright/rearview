#
# Vagrant setup for rearview using virtualbox as the provider
# and docker as the provisioner. The Vagrant box image is a
# 64-bit Ubuntu 12.04 LTS box that has Chef/Puppet 
# pre-installed
#
$setup = <<SCRIPT
# Stop and remove any existing containers
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)

# Build containers from Dockerfiles
docker build -t postgres /app/docker/postgres
docker build -t rails /app
docker build -t redis /app/docker/redis/

# Run and link the containers
docker run -d --name postgres -e POSTGRESQL_USER=docker -e POSTGRESQL_PASS=docker postgres:latest
docker run -d --name redis redis:latest
docker run -d -p 3000:3000 -v /app:/app --link redis:redis --link postgres:db --name rails rails:latest

SCRIPT

# Commands required to ensure correct docker containers
# are started when the vm is rebooted.
$start = <<SCRIPT
docker start postgres
docker start redis
docker start rails
SCRIPT

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure("2") do |config|

  # Setup resource requirements
  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
    v.cpus = 2
  end

  # need a private network for NFS shares to work
  config.vm.network "private_network", ip: "192.168.50.4"

  # Rails Server Port Forwarding
  config.vm.network "forwarded_port", guest: 3000, host: 3010

  # Ubuntu
  # config.vm.box = "hashicorp/precise64"
  config.vm.box = "phusion/ubuntu-14.04-amd64"

  # Must use NFS for this otherwise rails performance will be awful
  #
  # Only useful if we are setting up a development environment
  config.vm.synced_folder ".", "/app/rearview", type: "nfs"

  # Docker provisioning 
  config.vm.provision "docker" do |d|
    d.build_image "/app/rearview", args: "-t 'rearview'"
    d.run "rearview"
  end

  # Setup the containers when the VM is first
  # created
  # config.vm.provision "shell", inline: $setup

  # Make sure the correct containers are running
  # every time we start the VM.
  # config.vm.provision "shell", run: "always", inline: $start
end
