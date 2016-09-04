#
# Description: This method updates the service provisioning status
# Required inputs: status
#

prov = $evm.root['service_template_provision_task']

# Get status from input field status
status = $evm.inputs['status']

$evm.instantiate("/POC/Containers/Methods/DeleteProject")

# Update Status for on_entry,on_exit
if $evm.root['ae_result'] == 'ok' || $evm.root['ae_result'] == 'error'
  prov.message = status
end

$evm.root['ae_result'] = 'finished'

exit MIQ_ABORT
