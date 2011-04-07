#
# Cookbook Name:: nginx
# Recipe:: source
#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Joshua Timberman (<joshua@opscode.com>)
#
# Copyright 2009-2011, Opscode, Inc.
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
include_recipe "upstart"

packages = value_for_platform(
    ["centos","redhat","fedora"] => {'default' => ['pcre-devel', 'openssl-devel']},
    "default" => ['libpcre3', 'libpcre3-dev', 'libssl-dev']
  )

packages.each do |devpkg|
  package devpkg
end

nginx_version = node[:nginx][:version]

node.set[:nginx][:install_path]    = "/opt/nginx-#{nginx_version}"
node.set[:nginx][:src_binary]      = "#{node[:nginx][:install_path]}/sbin/nginx"
node.set[:nginx][:daemon_disable]  = false
node.set[:nginx][:configure_flags] = [
  "--prefix=#{node[:nginx][:install_path]}",
  "--conf-path=#{node[:nginx][:dir]}/nginx.conf",
  "--with-http_ssl_module",
  "--with-http_gzip_static_module",
  "--with-http_stub_status_module",
  "--with-http_realip_module",
]

node.set[:nginx][:default_site][:root] = "#{node.set[:nginx][:install_path]}/html"

configure_flags = node[:nginx][:configure_flags].join(" ")

remote_file "#{Chef::Config[:file_cache_path]}/nginx-#{nginx_version}.tar.gz" do
  source "http://sysoev.ru/nginx/nginx-#{nginx_version}.tar.gz"
  action :create_if_missing
end

bash "compile_nginx_source" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    tar zxf nginx-#{nginx_version}.tar.gz
    cd nginx-#{nginx_version} && ./configure #{configure_flags}
    make && make install
  EOH
  creates node[:nginx][:src_binary]
  notifies :restart, "service[nginx]"
end

group node[:nginx][:user]

user node[:nginx][:user] do
  comment "Nginx user"
  shell "/bin/false"
  system true
  gid node[:nginx][:user]
  home node[:nginx][:default_site][:root]
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

upstart_service "nginx"

%w{ sites-available sites-enabled conf.d }.each do |dir|
  directory "#{node[:nginx][:dir]}/#{dir}" do
    owner "root"
    group "root"
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


include_recipe "nginx::default_site"
