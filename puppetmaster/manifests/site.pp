import 'nodes/*.pp'
import 'classes/*.pp'
import 'classes/*/*.pp'

stage { 'pre': before => Stage['main'] }
stage { 'post': require => Stage['main'] }

