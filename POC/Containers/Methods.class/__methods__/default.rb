#
# Description: This method is executed when no specific method is specified
#

require 'kubeclient'

$evm.log("info", "--- Entering Default Container Method ---")

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

ocpconfig = OcpConfig.new

ocpconfig.set_config_by_parameters(cluster_master, no_verify_ssl,
                              pretty, debug, token,
  							  client_cert_location, 
  							  client_key_location,
                              client_ca_cert_location)

ocpapi = OcpApi.new
ocpapi.setup(ocpconfig)
ocpapi.list
$evm.log("info","OCP API ---- #{ocpapi.response}")


$evm.root["service_template_provision_task"].execute

$evm.log("info", "--- Exiting Default Container Method ---")
