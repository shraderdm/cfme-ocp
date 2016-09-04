#
# Description: <Method description here>
#
$evm.log("info","========== GOT HERE ==========")

tag = "/managed/environment/development"
hosts = $evm.vmdb 

$evm.log("info","========== #{hosts.inspect} ==========")
