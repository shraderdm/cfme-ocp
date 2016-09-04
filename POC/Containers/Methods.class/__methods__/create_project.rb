#Authorization: Bearer
# Description: This method launches the service provisioning job
require 'rest-client'
require 'json'
require 'ocp'

dialog_options = $evm.root["service_template_provision_task"].dialog_options
project_name = dialog_options['dialog_option_0_service_name']
project_display_name = dialog_options['dialog_option_0_display_name']
project_description = dialog_options['dialog_option_0_project_description']

$evm.log("info", "========= CREATING PROJECT =========")
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

projreq = ProjectRequest.new
projreq.setup(cluster_master, no_verify_ssl,
                              pretty, debug, token,
  							  client_cert_location, 
  							  client_key_location,
                              client_ca_cert_location)
response = projreq.createprojectrequest(project_name, project_display_name, project_description)
$evm.log("info", "======= END CREATING PROJECT =======")

$evm.root["service_template_provision_task"].execute


