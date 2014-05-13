#
# Cookbook Name:: nginx
# Attributes:: auth_ldap
#
# Copyright 2012, NREL
#
# All rights reserved - Do Not Redistribute
#

default['nginx']['auth_ldap']['version'] = 'v0.1'
default['nginx']['auth_ldap']['url'] = "https://github.com/kvspb/nginx-auth-ldap/archive/#{node['nginx']['auth_ldap']['version']}.tar.gz"
default['nginx']['auth_ldap']['checksum'] = '709ba34b524f5c27aad1cc50a53a2362b531ef03a195b0478fabafe7d221711a'
