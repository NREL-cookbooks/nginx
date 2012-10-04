#
# Cookbook Name:: nginx
# Recipe:: commons
# Author:: AJ Christensen <aj@junglist.gen.nz>
#
# Copyright 2008-2012, Opscode, Inc.
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

include_recipe "logrotate"

directory node['nginx']['dir'] do
  owner "root"
  group "root"
  mode "0755"
end

directory node['nginx']['log_dir'] do
  mode 0755
  owner node['nginx']['user']
  action :create
end

%w(sites-available sites-enabled).each do |dir|
  directory "#{node[:nginx][:dir]}/#{dir}" do
    owner "root"
    group(node[:common_writable_group] || "root")
    mode "0775"
  end
end

%w(conf.d).each do |leaf|
  directory File.join(node[:nginx][:dir], leaf) do
    owner "root"
    group "root"
    mode "0755"
  end
end

%w(nxensite nxdissite).each do |nxscript|
  template "/usr/sbin/#{nxscript}" do
    source "#{nxscript}.erb"
    mode "0755"
    owner "root"
    group "root"
  end
end

template "nginx.conf" do
  path "#{node['nginx']['dir']}/nginx.conf"
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :reload, 'service[nginx]', :immediately
end

%w{ fastcgi_params scgi_params uwsgi_params }.each do |param_file|
  template "#{node[:nginx][:dir]}/#{param_file}" do
    source "#{param_file}.erb"
    owner "root"
    group "root"
    mode "0644"
    notifies :reload, "service[nginx]"
  end
end

template "#{node['nginx']['dir']}/sites-available/default" do
  source "default-site.erb"
  owner "root"
  group "root"
  mode 0644
end

nginx_site 'default' do
  enable node['nginx']['default_site_enabled']
end

logrotate_app "nginx" do
  path ["#{node[:nginx][:log_dir]}/*.log", node[:nginx][:logrotate][:extra_paths]].flatten
  frequency "daily"
  rotate node[:nginx][:logrotate][:rotate]
  create "644 #{node[:nginx][:user]} root"
  cookbook "nginx"
end
