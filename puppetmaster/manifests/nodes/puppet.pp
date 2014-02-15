#
# Puppet Servers
#
node /^puppet1.puppet.local/ inherits generic {
}

node 'puppetmaster' inherits generic {
}

node /^ops-puppetdashboard-\d+/ inherits generic {
}
node /^ops-puppet-dashboard-\d+/ inherits generic {
}

node /^ops-puppet-db-\d+/ inherits generic {
}

node /^ops-puppet-ca-/ inherits puppetmaster {
}

node /^ops-puppet-worker-/ inherits puppetmaster {
}
