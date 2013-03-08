default[:nginx][:passenger][:version] = "3.0.19"

# General
default[:nginx][:passenger][:spawn_method] = "smart-lv2"
default[:nginx][:passenger][:use_global_queue] = true

# Security
default[:nginx][:passenger][:user_switching] = true
default[:nginx][:passenger][:default_user] = "nobody"
default[:nginx][:passenger][:default_group] = nil
default[:nginx][:passenger][:friendly_error_pages] = true

# Resource control and optimization
default[:nginx][:passenger][:max_pool_size] = 6
default[:nginx][:passenger][:min_instances] = 1
default[:nginx][:passenger][:max_instances_per_app] = 0
default[:nginx][:passenger][:pool_idle_time] = 300
default[:nginx][:passenger][:max_requests] = 0
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
