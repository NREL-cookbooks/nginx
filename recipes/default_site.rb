#
# Cookbook Name:: nginx
# Recipe:: default_site
#
# Copyright 2011, NREL
#
# All rights reserved - Do Not Redistribute
#

template "#{node[:nginx][:dir]}/sites-available/default" do
  source "default-site.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :reload, "service[nginx]"
end

nginx_site "default" do
  enable node[:nginx][:default_site][:enable]
end
