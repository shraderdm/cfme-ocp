# CloudForms and OpenShift Container Platform Integration
As of CloudForms 4.0, not only can one monitor and manage cloud workloads, but container workloads as well.  CloudForms provides a single pane of glass view into a hybrid cloud infrastructure.  From one interface a user can interact with both their IaaS and their PaaS.

CloudForms 4.1 brought many improvements for both IaaS and PaaS.  This automate model allows a user to provision an OCP project via a CloudForms Service Catalog Item (more features to come).  This is useful if the OCP administrators wish to disable the self-service provisioner capability in OCP, and add an approval workflow to provisioning a project

This relies on the [OCP Ruby Gem](https://github.com/kevensen/ocpcmd).

If you wish to checkout the upstream project for CloudForms, take a look at [ManageIQ](http://manageiq.org/).

## Prerequisites
1. Install the [OpenShift Container Platform](https://docs.openshift.com/enterprise/3.2/install_config/install/index.html)
  * Though not necessary, if you wish to disable the self-service provisioner capability, see the [administration documentation](https://docs.openshift.com/enterprise/3.2/admin_guide/managing_projects.html)
2. Deploy CloudForms 4.1 (or ManageIQ).  I recommend one appliance configured for database management and two for doing the actual work.  The following sections provide a recommended configuration.
3. At this point, the automate model relies on LDAP a little bit.  I recommend FreeIPA (Red Hat Identity Manager).

## CloudForms Configuration
As was mentioned earlier, a deployment of three appliances is recommended: one database appliance and at least two worker appliances.  I won't get into the deployment of the appliances but I will discuss the recommended configuration through the WebUI.

At this point I'll assume you've deployed and executed initial configuration for one database and two worker appliances.

### CFME Appliance configuration
Once you've deployed the database appliance, navigate to the database appliance's web console.
* Settings --> Configuration
#### Server Configuration
For each appliance, do the following
1. Provide a **Company Name** (e.g. MyCompany)
2. Provide an **Appliance Name** (e.g. CFMEDB)
3. Set your timezone
4. Apply the **Server Roles**.  Please note these are only recommended settings.

| Role | CFMEDB | CFMEWK1 | CFMEWK2 |
| ---- | ------ | ------- | ------- |
| Automation Engine | Off | On | On |
| Capacity & Utilization Coordinator | Off | On | On |
| Capacity & Utilization Data Collector | Off | On | On |
| Capacity & Utilization Data Processor | Off | On | On |
| Database Operations | On | Off | Off |
| Database Synchronization | Off | Off | Off |
| Event Monitor | Off | On | On |
| Git Repositories Owner | Off | Off | Off |
| Notifier | On | Off | Off |
| Provider Inventory | Off | On | On |
| Provider Operations | Off | On | On |
| RHN Mirror | Off | On | On |
| Reporting | Off | On | On |
| Secheduler | Off | On | On |
| SmartProxy | Off | On | On |
| SmartState Analysis | Off | On | On |
| User Interface | On | Off | Off |
| Web Services | On | Off | Off |
| Websocket | On | Off | Off |

5. Configure e-mail (if desired, but I recommend it).  I used Gmail in this example.
  * Host: smtp.gmail.com
  * Port: 587
  * Domain: gmail.com
  * Start TLS Automatically: On
  * SSL Verify Mode: None
  * Authentication: login
  * User Name: *Your Gmail login with the @gmail.com*
  * Password: Your gmail application Password
  * From E-mail Address: This could be anything

#### Tags
We need to add some tags to affect how OCP projects are provisioned.
* Settings --> Configuration
In the pane on the left, choose the appropriate **CFME Region: Region N [N]**.  There may be only one.  

When creating tags, we must first create some categories.

| Name  | Description | Long Description | Show in Console | Single Value | Capture C&U Data by Tag |
| ----- | ----------- | ---------------- | --------------- | ------------ | ----------------------- |
| quota_ocp_pods | Quota OCP Pods | Quota OCP Pods | On | On | Off |
| quota_ocp_pvc | Quota OCP Persistent Volume Claims | Quota OCP Persistent Volume Claims | On | On | Off |
| quota_ocp_rc | Quota OCP Replication Controller Count | Quota OCP Replication Controller Count | On | On | Off |
| quota_ocp_secrets | Quota OCP Secrets | Quota OCP Secrets | On | On | Off |
| quota_ocp_services | Quota OCP Services | Quota OCP Services | On | On | Off |
| ldap_manager_attribute | LDAP Manager Attribute | LDAP Manager Attribute | On | On | Off |
| ldap_username_attribute | LDAP User Name Attribute | LDAP User Name Attribute | On | On | Off |
| ocp_project_role | Default Requester Project Role | Default Requester Project Role | On | On | Off |

Now we can add values to the tags.  For each of the categories above, create the following **recommended** values.

**Quota OCP Pods**

| Name | Description |
| ---- | ----------- |
| 100 | 100 |
| 25 | 25 |
| 50 | 50 |

**Quota OCP Persistent Volume Claims**

| Name | Description |
| ---- | ----------- |
| 1 | 1 |
| 10 | 10 |
| 5 | 5 |

**Quota OCP Replication Controller Count**

| Name | Description |
| ---- | ----------- |
| 10 | 10 |
| 20 | 20 |
| 50 | 50 |

**Quota OCP Secrets**

| Name | Description |
| ---- | ----------- |
| 10 | 10 |
| 20 | 20 |
| 5 | 5 |

**Quota OCP Services**

| Name | Description |
| ---- | ----------- |
| 100 | 100 |
| 25 | 25 |
| 50 | 50 |

**LDAP Manager Attribute**

| Name | Description |
| ---- | ----------- |
| manager | Manager |

**LDAP User Name Attribute**

| Name | Description |
| ---- | ----------- |
| uid | UID |

**Default Requester Project Role**

| Name | Description |
| ---- | ----------- |
| admin | Administrator |
| edit | Editor |
| view | Viewer |

#### Applying the tags
Each of the above tags get applied to a group.  Groups are configured under **Access Control**.
* Settings --> Configuration --> Access Control

Under **Groups** select the group to which to apply the tags.  Then go to **Policy** at the top and select the *Edit <Company> Tags for this Group*.

### Automation Configuration
#### Creating the Custom Service Dialog
The dialog being created will resemble the web form presented when one provisions a new project through the OpenShift web interface.
* Automate --> Customization --> Service Dialogs

From the **Configuration** dropdown choose **Add a new Dialog**

Name this the *project-request-dialog*.  Give it a *Submit* and *Cancel* button.

1. Add a tab named *Basic Info*
2. Add a box named *General*
3. Add the following elements.

| Label | Name | Description | Type | Required |  Validator Rule |
| ----- | ---- | ----------- | ---- | -------- | -------------- |
| Project Name | option_0_service_name | Project name may only container lowercase letters and numbers | Text Box | Yes | ^[a-z0-9]*$ |
| Project Display Name | option_0_display_name  | | Text Box | No | |
| Project Description | option_0_project_description | | Text Area Box | No |  |

Save

#### Importing the Automate model
**Download the Model**

1. Navigate to https://github.com/kevensen/cfme-ocp
2. Clone the repository

**ZIP the Repository**

1. In your file system, navigate to you cloned folder
2. Use your favorite archive utility to zip the POC folder as a **ZIP** archive

**Import the Model**

1. In CFME, navigate to *Automate --> Import / Export*
2. In the *Import Datastore Classes* dialog, click *Choose File*
3. In the file choose, find and select the ZIP file you created
4. Click *Upload*
5. On the next screen, the only option to change is the *Toggle All/None* to ensure that all components are selected.  Leave defaults for the other options.
6. Click *Commit*

**Enable the Model**

1. Navigate to *Automate --> Explorer*
2. In the tree select *POC*
3. Click on *Configuration* in the button bar
4. Click *Edit this Domain*
5. Check the *Enabled Box* if it is not enabled
