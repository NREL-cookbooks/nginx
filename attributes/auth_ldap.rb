#
# Cookbook Name:: nginx
# Attributes:: auth_ldap
#
# Copyright 2012, NREL
#
# All rights reserved - Do Not Redistribute
#

default['nginx']['auth_ldap']['version'] = '0.1'
default['nginx']['auth_ldap']['url'] = "https://github.com/downloads/kvspb/nginx-auth-ldap/nginx-auth-ldap-0.1.tar.gz"
default['nginx']['auth_ldap']['checksum'] = '3929dc54e2a847df04319fdc60e30bdb5e0be6e3ca4d6d98f51d529d50027b25'
