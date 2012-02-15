#
# organization - selects your cloud environment.
# username     - selects your client key and user-specific overrides
# homebase     - default location for clusters, cookbooks and so forth
#
username            ENV['CHEF_USER'] || ENV['USER']
homebase            ENV['CHEF_HOMEBASE'] ? File.expand_path(ENV['CHEF_HOMEBASE']) : File.expand_path("..", File.dirname(__FILE__))

#
# Additional settings and overrides
#

def load_if_exists(file) ; load(file) if File.exists?(file) ; end

#
# Clusters, cookbooks and roles
#
cluster_path        [ "#{homebase}/clusters"  ]
cookbook_path       [ "#{homebase}/cookbooks" ]
role_path           [ "#{homebase}/roles"     ]

#
# Keys and cloud-specific settings.
# Be sure all your .pem files are non-readable (mode 0600)
#
credentials_path    File.expand_path("credentials", File.dirname(__FILE__))
client_key_dir      "#{credentials_path}/client_keys"
ec2_key_dir         "#{credentials_path}/ec2_keys"

#
# Load the vendored cluster_chef lib if present
#
if File.exists?("#{homebase}/vendor/cluster_chef/lib")
  $LOAD_PATH.unshift("#{homebase}/vendor/cluster_chef/lib")
end

log_level               :info
log_location            STDOUT
node_name               username
client_key              "#{credentials_path}/#{username}.pem"
cache_type              'BasicFile'
cache_options           :path => "/tmp/chef-checksums-#{username}"

#
# Configure client bootstrapping
#
bootstrap_runs_chef_client true
bootstrap_chef_version  "~> 0.10.4"

# Organization-sepecific settings -- Chef::Config[:ec2_image_info] and so forth
#
# This must do at least these things:
#
# * define Chef::Config.chef_server
# * define Chef::Config.organization
#
#
load_if_exists "#{credentials_path}/knife-org.rb"
# User-specific knife info or credentials
load_if_exists "#{credentials_path}/knife-user-#{username}.rb"
