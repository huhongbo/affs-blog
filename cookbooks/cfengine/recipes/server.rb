#
# Cookbook Name:: cfengine
# Recipe:: server
#
# Copyright 2011, afistfulofservers
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

node.set[:cfengine][:server]=true

cfengine_clients = search(:node, 'cfengine_client:true')

#######################################################
# packages
#######################################################

# cfengine
package "cfengine"

#######################################################
# files, templates, and directories
#######################################################

# masterfiles
directory "/var/cfengine/masterfiles" do
  action :create
end

# cfengine input files
%w{ inputs masterfiles }.each do |dir|
  %w{ failsafe cfengine_stdlib global garbage_collection cfengine }.each { |c|
    template "/var/cfengine/#{dir}/#{c}.cf" do
      source "inputs/#{c}.cf.erb"
      variables( :cfengine_server => node )
      notifies :restart, "service[cf-serverd]"
    end
  }

  # updates
  template "/var/cfengine/#{dir}/update.cf" do
    source "inputs/update.cf.erb"
    notifies :restart, "service[cf-serverd]"
  end
end

# promises.cf
template "/var/cfengine/inputs/promises.cf" do
  source "inputs/promises-server.cf.erb"
  variables( :cfengine_clients => cfengine_clients )
  notifies :restart, "service[cf-serverd]"
end


#######################################################
# Distribution only
#######################################################

# promises.cf
template "/var/cfengine/masterfiles/promises.cf" do
  source "inputs/promises-client.cf.erb"
  variables( :cfengine_clients => cfengine_clients )
  notifies :restart, "service[cf-serverd]"
end

# puppet.cf
template "/var/cfengine/masterfiles/puppet.cf" do
  source "inputs/puppet.cf.erb"
  variables( :cfengine_clients => cfengine_clients )
  notifies :restart, "service[cf-serverd]"
end

## puppet server policy distribution
directory "/var/cfengine/masterfiles/puppet" do
  action :create
end

# puppet/site.pp
template "/var/cfengine/masterfiles/puppet/site.pp" do
  source "puppet/site.pp.erb"
  variables( :cfengine_clients => cfengine_clients )
  notifies :restart, "service[cf-serverd]"
end


#######################################################
# services
#######################################################

# poke a hole in the firewall
# FIXME Do this properly once COOK-688 is done
service "iptables" do
  action [:disable,:stop]
end

cfengine_services = %w{
  cf-execd
  cf-serverd
}

# services
cfengine_services.each { |s|
  service "#{s}" do
    action [:enable,:start]
  end
}

