# Prerequisites
1. Install the [OpenShift Container Platform](https://docs.openshift.com/enterprise/3.2/install_config/install/index.html)
  * Though not necessary, if you wish to disable the self-service provisioner capability, see the [administration documentation](https://docs.openshift.com/enterprise/3.2/admin_guide/managing_projects.html)
2. Deploy CloudForms 4.1 (or ManageIQ).  I recommend one appliance configured for database management and two for doing the actual work.  The following sections provide a recommended configuration.
3. At this point, the automate model relies on LDAP a little bit.  I recommend FreeIPA (Red Hat Identity Manager).
4. Until a future release of CloudForms, it will be necessary to topy the *system:admin* user certs from one of your OpenShift masters to each CFME worker appliance.  I recommend placing these in the /root directory on the CFME worker appliance(s).
 * /etc/origin/master/admin.crt
 * /etc/origin/master/admin.key
 * /etc/origin/master/ca.crt
5. The [Kubeclient Ruby Gem](https://github.com/abonas/kubeclient.git) is required on each worker appliance.
