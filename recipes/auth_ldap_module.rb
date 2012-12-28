#
# Cookbook Name:: nginx
# Recipe:: auth_ldap
#
# Copyright 2012, NREL
#
# All rights reserved - Do Not Redistribute
#

package "openldap-devel"

src_filename = "nginx-auth-ldap-#{node['nginx']['auth_ldap']['version']}.tar.gz"
src_filepath = "#{Chef::Config['file_cache_path']}/#{src_filename}"
extract_path = "#{Chef::Config['file_cache_path']}/nginx_auth_ldap_module-#{node['nginx']['auth_ldap']['version']}/#{node['nginx']['auth_ldap']['checksum']}"

remote_file src_filepath do
  source   node['nginx']['auth_ldap']['url']
  checksum node['nginx']['auth_ldap']['checksum']
  owner    'root'
  group    'root'
  mode     0644
end

bash 'extract_auth_ldap_module' do
  cwd ::File.dirname(src_filepath)
  code <<-EOH
    mkdir -p #{extract_path}
    tar xzf #{src_filename} -C #{extract_path}
    mv #{extract_path}/*/* #{extract_path}/
  EOH

  not_if { ::File.exists?(extract_path) }
end

node.run_state['nginx_configure_flags'] =
  node.run_state['nginx_configure_flags'] | ["--add-module=#{extract_path}"]
