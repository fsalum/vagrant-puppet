import 'nodes/server.pp'

stage { 'pre': before => Stage['main'] }
stage { 'post': require => Stage['main'] }
