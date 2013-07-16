#
# Cookbook Name:: nginx
# Attribute:: passenger
#
# Author:: Alex Dergachev (<alex@evolvingweb.ca>)
#
# Copyright 2013, Opscode, Inc.
# Copyright 2012, Susan Potter
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
node.default["nginx"]["passenger"]["version"] = "3.0.19"

if node["languages"].attribute?("ruby")
  node.default["nginx"]["passenger"]["root"] = "#{node['languages']['ruby']['gems_dir']}/gems/passenger-#{node['nginx']['passenger']['version']}"
  node.default["nginx"]["passenger"]["ruby"] = node['languages']['ruby']['ruby_bin']
else
  Chef::Log.warn("node['languages']['ruby'] attribute not detected in #{cookbook_name}::#{recipe_name}")
  Chef::Log.warn("Install a Ruby for automatic detection of node['nginx']['passenger'] attributes (root, ruby)")
  Chef::Log.warn("Using default values that may or may not work for this system.")
  node.default["nginx"]["passenger"]["root"] = "/usr/lib/ruby/gems/1.8/gems/passenger-#{node['nginx']['passenger']['version']}"
  node.default["nginx"]["passenger"]["ruby"] = "/usr/bin/ruby"
end

node.default["nginx"]["passenger"]["max_pool_size"] = 10
node.default["nginx"]["passenger"]["spawn_method"] = "smart-lv2"
node.default["nginx"]["passenger"]["use_global_queue"] = "on"
node.default["nginx"]["passenger"]["buffer_response"] = "on"
node.default["nginx"]["passenger"]["max_pool_size"] = 6
node.default["nginx"]["passenger"]["min_instances"] = 1
node.default["nginx"]["passenger"]["max_instances_per_app"] = 0
node.default["nginx"]["passenger"]["pool_idle_time"] = 300
node.default["nginx"]["passenger"]["max_requests"] = 0
node.default["nginx"]["passenger"]["gem_binary"] = nil


# General

# Security
default[:nginx][:passenger][:user_switching] = true
default[:nginx][:passenger][:default_user] = "nobody"
default[:nginx][:passenger][:default_group] = nil
default[:nginx][:passenger][:friendly_error_pages] = true

# Resource control and optimization
default[:nginx][:passenger][:max_preloader_idle_time] = 300
default[:nginx][:passenger][:stat_throttle_rate] = 0
default[:nginx][:passenger][:pre_start_urls] = []
default[:nginx][:passenger][:high_performance] = false

# Compatibility
default[:nginx][:passenger][:resolve_symlinks_in_document_root] = false
default[:nginx][:passenger][:allow_encoded_slashes] = false

# Logging and debugging
default[:nginx][:passenger][:log_level] = 0
default[:nginx][:passenger][:debug_log_file] = nil

# Ruby on Rails-specific
default[:nginx][:passenger][:rails_auto_detect] = true
default[:nginx][:passenger][:rails_base_uri] = nil
default[:nginx][:passenger][:rails_env] = "production"
default[:nginx][:passenger][:rails_framework_spawner_idle_time] = 1800
default[:nginx][:passenger][:rails_app_spawner_idle_time] = 600

# Rack-specific
default[:nginx][:passenger][:rack_auto_detect] = true
default[:nginx][:passenger][:rack_base_uri] = nil
default[:nginx][:passenger][:rack_env] = "production"
