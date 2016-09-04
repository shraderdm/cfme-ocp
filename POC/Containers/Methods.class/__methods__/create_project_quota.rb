#
# Description: create_project_quota
#
require 'rest-client'
require 'json'
require 'ocp'

task = $evm.root["service_template_provision_task"]
dialog_options = task.dialog_options
project_name = dialog_options['dialog_option_0_service_name']

$evm.log("info","==== CREATING QUOTA FOR PROJECT #{project_name} ====")

#Get the requester from the provision object
user = task.miq_request.requester
raise "User not specified" if user.nil?

$evm.log("info"," Detected requester is #{user.name}")

#Get the user's current group
group = user.current_group

$evm.log("info"," Detected requester's group is #{group}")

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

quota = ResourceQuota.new(project_name)
quota.setup(cluster_master, no_verify_ssl,
                              pretty, debug, token,
  							  client_cert_location, 
  							  client_key_location,
                              client_ca_cert_location)
resp = quota.create_resource_quota(project_name,
  group.tags("quota_ocp_pods")[0],
  group.tags("quota_ocp_rc")[0],
  group.tags("quota_ocp_services")[0],
  group.tags("quota_ocp_secrets")[0],
  group.tags("quota_ocp_pvc")[0])

$evm.log("info","Response => #{resp}")

$evm.log("info","======= END PROJECT QUOTA FOR PROJECT =======")
