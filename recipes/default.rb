include_recipe 'backup_lwrp::default'

if node['backup']['gem_bin_dir'].nil?
  package "ruby-full"
  backup_lwrp_install node.name
end

backup_lwrp_generate_config node.name do
  cookbook 'backup_lwrp'
end

backup_lwrp_generate_model node.name do
  gem_bin_dir node['backup']['gem_bin_dir']
  database_type "PostgreSQL"
  store_with({
    "engine" => "S3",
    "settings" => {
      "s3.access_key_id" => "#{node['backup']['aws']['access_key_id']}",
      "s3.secret_access_key" => "#{node['backup']['aws']['secret_access_key']}",
      "s3.region" => "eu-central-1",
      "s3.bucket" => "#{node['backup']['aws']['bucket']}",
      "s3.path" => "/",
      "s3.keep" => node['backup']['aws']['keep']
    }
  })
  options({
    'db.name' => "\"#{node['backup']['database']['name']}\"",
    'db.username' => "\"#{node['backup']['database']['username']}\"",
    'db.password' => "\"#{node['backup']['database']['password']}\"",
    'db.additional_options' => "['-xc', '-E=utf8']",
    'db.host' => '"localhost"'
  })
  hour '*'
  action :backup
end

major_version = node['backup']['major_version']
execute 'update Backup version in config' do
  command "sed -i 's|Backup v4.x|Backup v#{major_version}.x|' /opt/backup/config.rb"
end
