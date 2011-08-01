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
include_recipe "iptables::http"
include_recipe "iptables::https"

unless platform?("centos","redhat","fedora")
  include_recipe "runit"
end

packages = value_for_platform(
    ["centos","redhat","fedora"] => {'default' => ['pcre-devel', 'openssl-devel']},
    "default" => ['libpcre3', 'libpcre3-dev', 'libssl-dev']
  )

packages.each do |devpkg|
  package devpkg
end

nginx_version = node[:nginx][:version]

node.set[:nginx][:install_path]    = "/opt/nginx"
node.set[:nginx][:src_binary]      = "#{node[:nginx][:install_path]}/sbin/nginx"
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
  source "http://nginx.org/download/nginx-#{nginx_version}.tar.gz"
  action :create_if_missing
end

# Explicitly uncompress nginx source, regardless of whether or not it needs to
# be installed, so Passenger can compile against it.
execute "uncompress_nginx_source" do
  cwd Chef::Config[:file_cache_path]
  command "tar zxf nginx-#{nginx_version}.tar.gz"
  creates "#{Chef::Config[:file_cache_path]}/nginx-#{nginx_version}"
end

bash "compile_nginx_source" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    cd nginx-#{nginx_version} && ./configure #{configure_flags}
    make && make install
  EOH
  not_if "#{node[:nginx][:src_binary]} -v 2>&1 | grep 'nginx version: nginx/#{::Regexp.escape(nginx_version)}$'"

  # Make sure nginx is running and perform the binary upgrade if necessary.
  notifies :start, "service[nginx]"
  notifies :run, "bash[nginx_binary_upgrade]"
end

# When upgrading nginx between versions, use nginx fanciness to do so without
# downtime:
# http://wiki.nginx.org/CommandLine#Upgrading_To_a_New_Binary_On_The_Fly
bash "nginx_binary_upgrade" do
  action :nothing
  code <<-EOH
    PID_FILE="#{node[:nginx][:pid_file]}"
    OLDBIN_PID_FILE="${PID_FILE}.oldbin"
    PID=`cat ${PID_FILE}`

    # Test the config file.
    #{node[:nginx][:src_binary]} -t -c #{node[:nginx][:dir]}/nginx.conf
    retval=$?
    if [[ $retval -ne 0 ]]; then
      echo $"Error: Nginx configuration invalid. Binary upgrade failed. Manually restart?"
      exit 1
    fi

    # Make sure the PID file exists.
    if [[ ! -f ${PID_FILE} ]];  then
      echo $"Error: Nginx isn't running. Binary upgrade failed. Manually restart?"
      exit 1
    fi

    # Make sure a ".oldbin" PID file isn't already around.
    if [[ -f ${OLDBIN_PID_FILE} ]];  then
      echo $"Error: Nginx binary upgrade already in process? Manually restart?"
      exit 1
    fi

    # Send USR2 signal to start a new master process
    echo $"Staring new master nginx..."
    kill -s USR2 ${PID}

    sleep 1

    # If the new process got started, shutdown the old master with the QUIT
    # signal.
    if [[ -f ${OLDBIN_PID_FILE} && -f ${PID_FILE} ]];  then
      OLDBIN_PID=`cat ${OLDBIN_PID_FILE}`

      echo $"Graceful shutdown of old $prog..."
      kill -s QUIT ${OLDBIN_PID}
      exit 0
    else
      echo $"Error: Nginx binary upgrade failed. Manually restart?"
      exit 1
    fi
  EOH
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
  notifies :reload, "service[nginx]"
end

cookbook_file "#{node[:nginx][:dir]}/mime.types" do
  source "mime.types"
  owner "root"
  group "root"
  mode "0644"
  notifies :reload, "service[nginx]"
end

include_recipe "nginx::default_site"

unless platform?("centos","redhat","fedora")
  node.set[:nginx][:daemon_disable] = true

  runit_service "nginx"

  service "nginx"
else
  #install init db script
  template "/etc/init.d/nginx" do
    source "nginx.init.erb"
    owner "root"
    group "root"
    mode "0755"
  end

  #install sysconfig file (not really needed but standard)
  template "/etc/sysconfig/nginx" do
    source "nginx.sysconfig.erb"
    owner "root"
    group "root"
    mode "0644"
  end

  #register service
  service "nginx" do
    supports :status => true, :restart => true, :reload => true
    action [:enable, :start]
  end
end

