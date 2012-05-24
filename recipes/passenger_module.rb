#
# Cookbook Name:: nginx
# Recipe:: passenger_module
#
# Copyright 2012, NREL
#
# All rights reserved - Do Not Redistribute
#

include_recipe "passenger"

template "#{node[:nginx][:dir]}/conf.d/passenger.conf" do
  source "modules/passenger.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :reload, "service[nginx]"
end

node.run_state[:nginx_configure_flags] = node.run_state[:nginx_configure_flags] | ["--add-module=#{node[:passenger][:root_path]}/ext/nginx", "--with-cc-opt=-Wno-error"]
