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
docker build -t postgres /app/rearview/docker/postgres
docker build -t rearview /app/rearview

# Run and link the containers
docker run -d --name postgres -e POSTGRESQL_USER=docker -e POSTGRESQL_PASS=docker postgres:latest
# Run migrations
# docker run -u dobby -w "/app/rearview" -e "HOME=/home/dobby" -v /app:/app --link postgres:db -i -t rearview /bin/sh -c "RAILS_ENV=production /app/rearview/docker/rearview/rbenv-exec bundle exec rake rearview:setup"
docker run -d -p 3000:3000 -u dobby -w "/app/rearview" -e "HOME=/home/dobby" -e "RAILS_ENV=production" -v /app:/app --link postgres:db rearview:latest 
# docker run -d --name rearview -p 3000:3000 -v /app:/app --link postgres:db rearview:latest

SCRIPT

# Commands required to ensure correct docker containers
# are started when the vm is rebooted.
$start = <<SCRIPT
docker start postgres
docker start rearview
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
  config.vm.network "forwarded_port", guest: 3000, host: 3000

  # Ubuntu
  # config.vm.box = "hashicorp/precise64"
  config.vm.box = "phusion/ubuntu-14.04-amd64"

  # Must use NFS for this otherwise rails performance will be awful
  #
  # Only useful if we are setting up a development environment
  config.vm.synced_folder ".", "/app/rearview", type: "nfs"

  # Docker provisioning 
  # config.vm.provision "docker" do |d|
    # d.build_image "/app/rearview", args: "-t 'rearview'"
    # d.build_image "/app/rearview/docker/postres", args: "-t 'postgres'"
    # d.run "rearview"
  # end

  # Setup the containers when the VM is first
  # created
  config.vm.provision "shell", inline: $setup

  # Make sure the correct containers are running
  # every time we start the VM.
  config.vm.provision "shell", run: "always", inline: $start
end
