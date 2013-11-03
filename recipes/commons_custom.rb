include_recipe "logrotate"

include_recipe "nginx::commons_dir"
include_recipe "nginx::commons_conf"

%w{ fastcgi_params scgi_params uwsgi_params envvars }.each do |param_file|
  template "#{node[:nginx][:dir]}/#{param_file}" do
    source "#{param_file}.erb"
    owner "root"
    group "root"
    mode "0644"
    notifies :reload, "service[nginx]"
  end
end

logrotate_app "nginx" do
  path ["#{node[:nginx][:log_dir]}/*.log", node[:nginx][:logrotate][:extra_paths]].flatten
  frequency "daily"
  rotate node[:nginx][:logrotate][:rotate]
  create "644 #{node[:nginx][:user]} root"
  options %w(missingok compress delaycompress notifempty)
  sharedscripts true

  # Ideally we send nginx the "reopen" signal so a full reload isn't
  # necessary. But this doesn't properly rotate Pasenger's Rails log files,
  # so we'll do a "reload" instead.
  postrotate "#{node[:nginx][:binary]} -s reload"
end

