name              "lamp"
maintainer        "Edge Tor"
maintainer_email  "me@edgetor.com"
description       "Chef Cookbook to install Apache2.4, PHP5.5, Composer, and setup VirtualHost"
version           "1.0.0"

recipe "server", "Chef Cookbook to install Apache2.4, PHP5.5, Composer, and setup VirtualHost"

depends "apache"
depends "apt"
depends "npm"

%w{ debian ubuntu }.each do |os|
  supports os
end
