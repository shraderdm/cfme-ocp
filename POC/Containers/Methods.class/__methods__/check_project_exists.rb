require 'rest-client'
require 'json'
require 'ocp'

$evm.log("info", "Listing Root Object Attributes:")
$evm.root.attributes.sort.each { |k, v| $evm.log("info", "\t#{k}: #{v}") }
$evm.log("info", "===========================================")

dialog_options = $evm.root["service_template_provision_task"].dialog_options
project_name = dialog_options['dialog_option_0_service_name']

user_role = dialog_options['dialog_option_0_user_role']
user = $evm.root['user']
user_name = user.get_ldap_attribute("uid")

$evm.log("info", "========= BEGIN CHECKING IF PROJECT #{project_name} EXISTS =========")
token = $evm.object['token']
cluster_url = $evm.object['cluster_url']
cluster_api_port = $evm.object['cluster_api_port']
no_verify_ssl = $evm.object['no_verify_ssl']

debug = $evm.object['debug']
pretty = $evm.object['pretty']

client_cert_location = $evm.object['client_cert_location']
client_key_location = $evm.object['client_key_location']
client_ca_cert_location = $evm.object['client_ca_cert_location']

cluster_master = cluster_url + ":" + cluster_api_port.to_s

proj = Project.new
proj.setup(cluster_master, no_verify_ssl,
                              pretty, debug, token,
  							  client_cert_location, 
  							  client_key_location,
                              client_ca_cert_location)

if proj.exists?(project_name)
  $evm.root['ae_result'] = 'ok'
  $evm.log("info","Project #{project_name} has been created.")
else
  $evm.root['ae_result']         = 'retry'
  $evm.root['ae_retry_interval'] = '30.seconds'
  $evm.log("info","Project #{project_name} not yet created.  Retrying in 30 seconds.")
end

$evm.log("info", "====== END CHECKING IF PROJECT #{project_name} EXISTS ======")
