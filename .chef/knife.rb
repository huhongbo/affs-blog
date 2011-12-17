log_level            :info
log_location         STDOUT
node_name           'knife'
cache_type          'BasicFile'
cache_options( :path => "~/.chef/checksums" )
client_key       '~/.chef/knife.key.pem'

cookbook_path       [ "~/mychefrepo/cookbooks" ]
cookbook_copyright "example org"
cookbook_email     "cookbooks@example.net"
cookbook_license   "apachev2"

chef_server_url    "http://y.t.b.d:4000"

validation_key      "~/.chef/validation.pem"

# rackspacecloud
knife[:rackspace_api_key] = '00000000000000000000000000000000'
knife[:rackspace_username] = 'rackspace'

# slicehost
knife[:slicehost_password] = '0000000000000000000000000000000000000000000000000000000000000000'

# AFFS aws
knife[:aws_access_key_id]     = '00000000000000000000'
knife[:aws_secret_access_key] = '0000000000000000000000000000000000000000'

