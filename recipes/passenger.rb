#
# Cookbook Name:: nginx
# Recipe:: Passenger
#
# Copyright 2013, Opscode, Inc.
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

include_recipe "rbenv::system"

# Set these attributes here, rather than in the attributes file, so the rbenv
# cookbook has a chance to override them.
if node["languages"].attribute?("ruby")
  node.default["nginx"]["passenger"]["root"] = "#{node['languages']['ruby']['gems_dir']}/gems/passenger-#{node['nginx']['passenger']['version']}"
  node.default["nginx"]["passenger"]["ruby"] = node['languages']['ruby']['ruby_bin']
end

packages = value_for_platform_family(
  %w[rhel]   => %w[ruby-devel curl-devel],
  %w[debian] => %w[ruby-dev libcurl4-gnutls-dev]
)

packages.each do |name|
  package name
end

rbenv_gem 'rake'

rbenv_gem 'passenger' do
  action     :install
  version    node['nginx']['passenger']['version']
end

template "#{node["nginx"]["dir"]}/conf.d/passenger.conf" do
  source 'modules/passenger.conf.erb'
  owner  'root'
  group  'root'
  mode   '0644'
  notifies :reload, 'service[nginx]'
end

node.run_state['nginx_configure_flags'] =
  node.run_state['nginx_configure_flags'] | ["--add-module=#{node["nginx"]["passenger"]["root"]}/ext/nginx"]
