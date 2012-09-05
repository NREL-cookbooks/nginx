#
# Cookbook Name:: nginx
# Recipe:: cyber_security
#
# Copyright 2012, NREL
#
# All rights reserved - Do Not Redistribute
#

include_recipe "nginx"

template "#{node[:nginx][:dir]}/conf.d/cyber_security.conf" do
  source "cyber_security.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :reload, "service[nginx]"
end
