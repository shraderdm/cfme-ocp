#Authorization: Bearer
# Description: This method launches the service provisioning job
require 'rest-client'
require 'json'
require 'kubeclient'

dialog_options = $evm.root["service_template_provision_task"].dialog_options
$evm.log("info", "========= CREATING PROJECT =========")
cluster_url = $evm.object['cluster_url']
cluster_api_port = $evm.object['cluster_api_port']
no_verify_ssl = $evm.object['no_verify_ssl']

debug = $evm.object['debug']
pretty = $evm.object['pretty']

client_cert_location = $evm.object['client_cert_location']
client_key_location = $evm.object['client_key_location']
client_ca_cert_location = $evm.object['client_ca_cert_location']

cluster_master = cluster_url + ":" + cluster_api_port.to_s + "/oapi"

ssl_options = {
  client_cert: OpenSSL::X509::Certificate.new(File.read(client_cert_location)),
  client_key:  OpenSSL::PKey::RSA.new(File.read(client_key_location)),
  ca_file:     client_ca_cert_location,
  verify_ssl: OpenSSL::SSL::VERIFY_NONE }

client = Kubeclient::Client.new cluster_master, "v1", ssl_options: ssl_options
client.discover
project = Kubeclient::ProjectRequest.new
project.metadata = {}
project.metadata.name = dialog_options['dialog_option_0_service_name']
project.displayName = dialog_options['dialog_option_0_display_name']
project.description = project_description = dialog_options['dialog_option_0_project_description']

response = client.create_project_request project
$evm.log("info", "======= END CREATING PROJECT =======")

$evm.root["service_template_provision_task"].execute


