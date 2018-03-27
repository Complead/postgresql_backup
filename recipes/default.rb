include_recipe 'backup_lwrp::default'

# package "ruby-full"
# backup_lwrp_install node.name
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
    'cookbook' => 'backup_lwrp',
    'db.name' => "\"#{node['backup']['database']['name']}\"",
    'db.username' => "\"#{node['backup']['database']['username']}\"",
    'db.password' => "\"#{node['backup']['database']['password']}\"",
    'db.additional_options' => "['-xc', '-E=utf8']",
    'db.host' => '"localhost"'
  })
  hour '*'
  action :backup
end
