#
# Cookbook Name:: puppet
# Recipe:: default
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

node.set[:puppet][:server]=true
node.set[:cfengine][:client]=true

cfengine_servers = search(:node, 'role:cfengine')

package "cfengine"

Chef::Log.info("DEBUG: cfengine_server: #{cfengine_servers[0]}")

#######################################################
# Promises for initial bootstrap. Will be overwritten by Cfengine.
#######################################################

# cfengine input files
%w{ cfengine_stdlib global garbage_collection cfengine }.each { |c|
  template "/var/cfengine/inputs/#{c}.cf" do
    source "inputs/#{c}.cf.erb"
    variables( :cfengine_server => cfengine_servers[0] )
    cookbook "cfengine"
  end
}

# failsafe.cf
template "/var/cfengine/inputs/failsafe.cf" do
  source "inputs/failsafe.cf.erb"
  variables( :cfengine_server => cfengine_servers[0] )
  cookbook "cfengine"
end

# update.cf
template "/var/cfengine/inputs/update.cf" do
  source "inputs/update.cf.erb"
  variables( :cfengine_server => cfengine_servers[0] )
  cookbook "cfengine"
end

# promises.cf
template "/var/cfengine/inputs/promises.cf" do
  source "inputs/promises-client.cf.erb"
  cookbook "cfengine"
end

#######################################################
# Go button
#######################################################

# bootstrap that sukka
execute "bootstrap cf-agent against #{cfengine_servers[0][:fqdn]}" do
  command "/var/cfengine/bin/cf-agent -K"
end


