default[:nginx][:src][:version]      = "0.7.67"
default[:nginx][:src][:install_path] = "/opt/nginx-#{nginx[:version]}"
default[:nginx][:src][:binary]   = "#{nginx[:install_path]}/sbin/nginx"
default[:nginx][:src][:checksum] = "396c95055d041950831a9ee8ff54473436f212cd770c6bad0aa795637007f747"
default[:nginx][:src][:configure_flags] = [
  "--prefix=#{nginx[:install_path]}",
  "--conf-path=#{nginx[:dir]}/nginx.conf",
  "--with-http_ssl_module",
  "--with-http_gzip_static_module"
]

case platform
when "debian","ubuntu"
  set[:nginx][:dir]     = "/etc/nginx"
  set[:nginx][:log_dir] = "/var/log/nginx"
  set[:nginx][:user]    = "www-data"
  set[:nginx][:binary]  = "/usr/sbin/nginx"
else
  set[:nginx][:dir]     = "/etc/nginx"
  set[:nginx][:log_dir] = "/var/log/nginx"
  set[:nginx][:user]    = "www-data"
  set[:nginx][:binary]  = "/usr/sbin/nginx"
end

default[:nginx][:gzip] = "on"
default[:nginx][:gzip_disable] = "msie6"
default[:nginx][:gzip_http_version] = "1.1"
default[:nginx][:gzip_comp_level] = "1"
default[:nginx][:gzip_proxied] = "off"
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
