name              "lamp"
maintainer        "Edge Tor"
maintainer_email  "me@edgetor.com"
description       "Chef Cookbook to install Apache2.4, PHP5.5, Composer, phpMyAdmin, and setup VirtualHost"
version           "1.0.0"

recipe "default", "Chef Cookbook to install Apache2.4, PHP5.5, Composer, phpMyAdmin, and setup VirtualHost"

depends "apache"
depends "apt"
depends "chef-php-extra"
depends "npm"
depends "openssl"
depends "php"


%w{ debian ubuntu }.each do |os|
  supports os
end
