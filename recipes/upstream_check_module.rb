src_filename = "nginx-x-rid-header-#{node['nginx']['x_rid_header']['version']}.tar.gz"
src_filepath = "#{Chef::Config['file_cache_path']}/#{src_filename}"
extract_path = "#{Chef::Config['file_cache_path']}/nginx-x-rid-header/#{node['nginx']['x_rid_header']['source_checksum']}"

remote_file src_filepath do
  source   node['nginx']['x_rid_header']['source_url']
  checksum node['nginx']['x_rid_header']['source_checksum']
  owner    'root'
  group    'root'
  mode     00644
end

bash 'extract_x_rid_header_module' do
  cwd ::File.dirname(src_filepath)
  code <<-EOH
    mkdir -p #{extract_path}
    tar xzf #{src_filename} -C #{extract_path}
    mv #{extract_path}/*/* #{extract_path}/
  EOH

  not_if { ::File.exists?(extract_path) }
end

node.run_state['nginx_configure_flags'] =
  node.run_state['nginx_configure_flags'] | ["--add-module=#{extract_path}", "--with-ld-opt='-l ossp-uuid'"]
