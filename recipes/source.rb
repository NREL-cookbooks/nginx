#
# Cookbook Name:: nginx
# Recipe:: source
#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Joshua Timberman (<joshua@opscode.com>)
#
# Copyright 2009, Opscode, Inc.
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

include_recipe "build-essential"

packages = value_for_platform(
    ["centos","redhat","fedora"] => {'default' => ['pcre-devel', 'openssl-devel']},
    "default" => ['libpcre3', 'libpcre3-dev', 'libssl-dev']
  )

packages.each do |devpkg|
  package devpkg
end

remote_file "/tmp/nginx-#{node[:nginx][:src][:version]}.tar.gz" do
  source "http://nginx.org/download/nginx-#{node[:nginx][:src][:version]}.tar.gz"
  checksum node[:nginx][:src][:checksum]
  action :create_if_missing
end

bash "compile_nginx_source" do
  cwd "/tmp"
  code <<-EOH
    tar zxf nginx-#{node[:nginx][:src][:version]}.tar.gz
    cd nginx-#{node[:nginx][:src][:version]} && ./configure #{node[:nginx][:src][:configure_flags].join(" ")}
    make && make install
  EOH
  creates node[:nginx][:src][:binary]
end

directory node[:nginx][:log_dir] do
  mode 0755
  owner node[:nginx][:user]
  action :create
end

directory node[:nginx][:dir] do
  owner "root"
  group "root"
  mode "0755"
end

#install init db script
template "/etc/init.d/nginx" do
  source "nginx.init.erb"
  owner "root"
  group "root"
  mode "0755"
end

#install sysconfig file (not really needed but standard)
template "/etc/default/nginx" do
  source "nginx.sysconfig.erb"
  owner "root"
  group "root"
  mode "0644"
end

#register service
service "nginx" do
  supports :status => true, :restart => true, :reload => true
  action :enable
  subscribes :restart, resources(:bash => "compile_nginx_source")
end


%w{ sites-available sites-enabled conf.d }.each do |dir|
  directory "#{node[:nginx][:dir]}/#{dir}" do
    owner "root"
    group(node[:common_writable_group] || "root")
    mode "0775"
  end
end

%w{nxensite nxdissite}.each do |nxscript|
  template "/usr/sbin/#{nxscript}" do
    source "#{nxscript}.erb"
    mode "0755"
    owner "root"
    group "root"
  end
end

template "nginx.conf" do
  path "#{node[:nginx][:dir]}/nginx.conf"
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "nginx")
end

cookbook_file "#{node[:nginx][:dir]}/mime.types" do
  source "mime.types"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "nginx")
end

directory "/var/www/nginx-default" do
  mode 0755
  owner node[:nginx][:user]
  action :create
end

template "#{node[:nginx][:dir]}/sites-available/default" do
  source "default-site.erb"
  owner "root"
  group "root"
  mode 0644
end
