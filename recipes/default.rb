#
# Cookbook Name:: lamp
# Recipe:: default
#

# Necessary Recipes
include_recipe "apt"
include_recipe "npm"

#Install APT & NPM Packages defined in Vagrant File
node['server']['apt_pkgs'].each do |apt_pkg|
  package apt_pkg
end

node['server']['npm_pkgs'].each do |npm_pkg|
  npm_package npm_pkg
end

# Add PPA for latest version of PHP5.5 and Apache 2.4
apt_repository "php55" do
	uri "http://ppa.launchpad.net/ondrej/php5/ubuntu"
	distribution node['lsb']['codename']
	components ["main"]
	keyserver "keyserver.ubuntu.com"
	key "E5267A6C"
end

apt_repository 'apache2' do
	uri 'http://ppa.launchpad.net/ondrej/apache2/ubuntu'
	distribution node['lsb']['codename']
	components ['main']
	keyserver 'keyserver.ubuntu.com'
	key 'E5267A6C'
end

# Install OpenSSL & Apache
include_recipe "openssl"
include_recipe "apache2"

apache_module "authz_default" do
  enable false
end

# Install PHP5.5
include_recipe "php"

# Install xdebug
include_recipe "chef-php-extra::xdebug"

# Install Composer
bash "composer" do
  code <<-EOH
    curl -s https://getcomposer.org/installer | php
    sudo mv composer.phar /usr/local/bin/composer
  EOH
end

# phpMyAdmin
# Read Database Password from Vagrant File
database_pwd = "#{node['server']['db_password']}"

# Unattended phpmyadmin installation
bash "phpmyadmin" do
  code <<-EOH
    sudo apt-get install -q -y debconf-utils
    export DEBIAN_FRONTEND=noninteractive
    echo 'phpmyadmin phpmyadmin/dbconfig-install boolean true' | sudo debconf-set-selections
    echo 'phpmyadmin phpmyadmin/app-password-confirm password #{database_pwd}' | sudo debconf-set-selections
    echo 'phpmyadmin phpmyadmin/mysql/admin-pass password #{database_pwd}' | sudo debconf-set-selections
    echo 'phpmyadmin phpmyadmin/mysql/app-pass password #{database_pwd}' | sudo debconf-set-selections
    echo 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2' | sudo debconf-set-selections
    sudo apt-get install -q -y phpmyadmin
    sudo sed -i '$ a\Include /etc/phpmyadmin/apache.conf' /etc/apache2/apache2.conf
    sudo apache2ctl restart
  EOH
end

#VHost Configuration
#Disable Default config file and restart Apache service
execute "a2dissite default" do 
  user "root"
  command "/usr/sbin/a2dissite 000-default"
  notifies :restart, resources(:service => "apache2")
end

# Read Server Name from Vagrant File
app_name = "#{node['server']['name']}"

# Add new config to Apache with app_name
# https://github.com/onehealth-cookbooks/apache2#web_app
web_app app_name + ".local" do
  server_name node['server']['server_name']
  server_aliases node['server']['server_aliases']
  docroot node['server']['docroot']
  log_dir node['apache']['log_dir'] 
end