default[:nginx][:version]      = "0.8.54"

case platform
when "debian","ubuntu"
  set[:nginx][:dir]     = "/etc/nginx"
  set[:nginx][:log_dir] = "/var/log/nginx"
  set[:nginx][:user]    = "www-data"
  set[:nginx][:binary]  = "/usr/sbin/nginx"
else
  set[:nginx][:dir]     = "/etc/nginx"
  set[:nginx][:log_dir] = "/var/log/nginx"
  set[:nginx][:user]    = "nginx"
  set[:nginx][:binary]  = "/usr/sbin/nginx"
end

default[:nginx][:gzip] = "on"
default[:nginx][:gzip_http_version] = "1.0"
default[:nginx][:gzip_comp_level] = "2"
default[:nginx][:gzip_proxied] = "any"
default[:nginx][:gzip_disable] = nil
default[:nginx][:gzip_types] = [
  "text/plain",
  "text/css",
  "application/x-javascript",
  "application/json",
  "text/xml",
  "application/xml",
  "application/xml+rss",
  "text/javascript"
]

default[:nginx][:keepalive]          = "on"
default[:nginx][:keepalive_timeout]  = 65
default[:nginx][:worker_processes]   = cpu[:total]
default[:nginx][:worker_connections] = 2048
default[:nginx][:server_names_hash_bucket_size] = 64

default[:nginx][:server_tokens] = "off"

default[:nginx][:default_site][:enable] = true
default[:nginx][:default_site][:port] = 80
default[:nginx][:default_site][:status][:enable] = true
default[:nginx][:default_site][:status][:allow] = "127.0.0.1";
default[:nginx][:default_site][:status][:deny] = "all";
