directory node[:nginx][:dir] do
  owner "root"
  group "root"
  mode "0755"
end

directory node[:nginx][:log_dir] do
  mode 0755
  owner node[:nginx][:user]
  action :create
end

%w(sites-available sites-enabled).each do |dir|
  directory "#{node[:nginx][:dir]}/#{dir}" do
    owner "root"
    group(node[:common_writable_group] || "root")
    mode "0775"
  end
end

%w(conf.d).each do |leaf|
  directory File.join(node[:nginx][:dir], leaf) do
    owner "root"
    group "root"
    mode "0755"
  end
end

%w(nxensite nxdissite).each do |nxscript|
  template "/usr/sbin/#{nxscript}" do
    source "#{nxscript}.erb"
    mode "0755"
    owner "root"
    group "root"
  end
end

template "nginx.conf" do
  path "#{node[:nginx][:dir]}/nginx.conf"
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :reload, 'service[nginx]', :immediately
end

%w{ fastcgi_params scgi_params uwsgi_params }.each do |param_file|
  template "#{node[:nginx][:dir]}/#{param_file}" do
    source "#{param_file}.erb"
    owner "root"
    group "root"
    mode "0644"
    notifies :reload, "service[nginx]"
  end
end

template "#{node[:nginx][:dir]}/sites-available/default" do
  source "default-site.erb"
  owner "root"
  group "root"
  mode 0644
end

nginx_site 'default'
