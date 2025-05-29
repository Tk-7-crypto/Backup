## Some useful commands included in Jenkins Builds


### Table of contents  
- [Some useful commands included in Jenkins Builds](#some-useful-commands-included-in-jenkins-builds)
  - [Table of contents](#table-of-contents)
  - [Pre-requisite to use this commands](#pre-requisite-to-use-this-commands)
  - [Retrieve Command](#retrieve-command)
      - [TARGETS (These targets are case sensitive)](#targets-these-targets-are-case-sensitive)
  - [Transformation Commands](#transformation-commands)
    - [Profile Transformation](#profile-transformation)
    - [LeadConvertSetting Transformation](#leadconvertsetting-transformation)
    - [All Transformation](#all-transformation)
  - [Sync and Deploy Developer Sandbox Commands](#sync-and-deploy-developer-sandbox-commands)
    - [Sync dev sandbox with master branch](#sync-dev-sandbox-with-master-branch)
    - [Deploy branch code into dev sandbox](#deploy-branch-code-into-dev-sandbox)


### Pre-requisite to use this commands
 * Please intall ant migration tool from [Apache Ant](https://ant.apache.org/bindownload.cgi)
 * Include ant bin path in system environment path param

### Retrieve Command
  > ant -file jenkins_build.xml -Dsf.username=\<username> -Dsf.password=\<password>\<securityToken> -Dsf.server=test.salesforce.com \<TARGETS>  
  **Note:** < > contains with your actual values.

##### TARGETS (These targets are case sensitive)  

- ###### **applications**
  applications target will fetch all the changes related to **_applications_** from your org directly in src folder. 
  
  > ant -file jenkins_build.xml -Dsf.username=xyz@abc.com.devops -Dsf.password=12345678Ydskalkdjlas -Dsf.server=test.salesforce.com applications

- ###### **approvalProcesses**  
  approvalProcesses target will fetch all the changes related to **_approval processes_** from your org directly in src folder.

  > ant -file jenkins_build.xml -Dsf.username=xyz@abc.com.devops -Dsf.password=12345678Ydskalkdjlas -Dsf.server=test.salesforce.com approvalProcesses

- ###### **aura**  
  aura target will fetch all the changes related to **_aura components_** from your org directly in src folder.
  
  > ant -file jenkins_build.xml -Dsf.username=xyz@abc.com.devops -Dsf.password=12345678Ydskalkdjlas -Dsf.server=test.salesforce.com aura

- ###### **authProvider**  
  authProvider target will fetch all the changes related to **_auth providers_** from your org directly in src folder.
  
  > ant -file jenkins_build.xml -Dsf.username=xyz@abc.com.devops -Dsf.password=12345678Ydskalkdjlas -Dsf.server=test.salesforce.com authProvider
     
- ###### **classes**  
  classes target will fetch all the changes related to **_apex classes_** from your org directly in src folder.
  
  > ant -file jenkins_build.xml -Dsf.username=xyz@abc.com.devops -Dsf.password=12345678Ydskalkdjlas -Dsf.server=test.salesforce.com classes
     
- ###### **components**  
  components target will fetch all the changes related to **_apex components_** from your org directly in src folder.
  
  > ant -file jenkins_build.xml -Dsf.username=xyz@abc.com.devops -Dsf.password=12345678Ydskalkdjlas -Dsf.server=test.salesforce.com components

- ###### **customLabels**  
  customLabels target will fetch all the changes related to **_custom labels_** from your org directly in src folder.
  
  > ant -file jenkins_build.xml -Dsf.username=xyz@abc.com.devops -Dsf.password=12345678Ydskalkdjlas -Dsf.server=test.salesforce.com customLabels
     
- ###### **customMetadata**  
  customMetadata target will fetch all the changes related to **_custom metadata_** from your org directly in src folder.
  
  > ant -file jenkins_build.xml -Dsf.username=xyz@abc.com.devops -Dsf.password=12345678Ydskalkdjlas -Dsf.server=test.salesforce.com customMetadata

- ###### **emailTemplate**  
  emailTemplate target will fetch all the changes related to **_email templates_** from your org directly in src folder.
  
  > ant -file jenkins_build.xml -Dsf.username=xyz@abc.com.devops -Dsf.password=12345678Ydskalkdjlas -Dsf.server=test.salesforce.com emailTemplate
     
- ###### **flexipages**  
  flexipages target will fetch all the changes related to **_flexi pages_** from your org directly in src folder.
  
  > ant -file jenkins_build.xml -Dsf.username=xyz@abc.com.devops -Dsf.password=12345678Ydskalkdjlas -Dsf.server=test.salesforce.com flexipages
     
- ###### **flow**  
  flow target will fetch all the changes related to **_flow_** from your org directly in src folder.
  
  > ant -file jenkins_build.xml -Dsf.username=xyz@abc.com.devops -Dsf.password=12345678Ydskalkdjlas -Dsf.server=test.salesforce.com flow
     
- ###### **globalValueSet**
  globalValueSet target will fetch all the changes related to **_global value set_** from your org directly in src folder.
  
  > ant -file jenkins_build.xml -Dsf.username=xyz@abc.com.devops -Dsf.password=12345678Ydskalkdjlas -Dsf.server=test.salesforce.com globalValueSet
     
- ###### **layouts**
  layouts target will fetch all the changes related to **_layouts_** from your org directly in src folder.
  
  > ant -file jenkins_build.xml -Dsf.username=xyz@abc.com.devops -Dsf.password=12345678Ydskalkdjlas -Dsf.server=test.salesforce.com layouts
     
- ###### **leadConvertSettings**
  leadConvertSettings target will fetch all the changes related to **_lead convert settings_** from your org directly in src folder.

  > ant -file jenkins_build.xml -Dsf.username=xyz@abc.com.devops -Dsf.password=12345678Ydskalkdjlas -Dsf.server=test.salesforce.com leadConvertSettings
     
- ###### **lwc**
  lwc target will fetch all the changes related to **_ligtning web components_** from your org directly in src folder.
  
  > ant -file jenkins_build.xml -Dsf.username=xyz@abc.com.devops -Dsf.password=12345678Ydskalkdjlas -Dsf.server=test.salesforce.com lwc
     
- ###### **matchingRule**
  matchingRule target will fetch all the changes related to **_matching Rule_** from your org directly in src folder.

  > ant -file jenkins_build.xml -Dsf.username=xyz@abc.com.devops -Dsf.password=12345678Ydskalkdjlas -Dsf.server=test.salesforce.com matchingRule
     
- ###### **objects**
  objects target will fetch all the changes related to **_objects_** from your org directly in src folder.
  
  > ant -file jenkins_build.xml -Dsf.username=xyz@abc.com.devops -Dsf.password=12345678Ydskalkdjlas -Dsf.server=test.salesforce.com objects
     
- ###### **pages**
  pages target will fetch all the changes related to **_visual force page_** from your org directly in src folder.
  
  > ant -file jenkins_build.xml -Dsf.username=xyz@abc.com.devops -Dsf.password=12345678Ydskalkdjlas -Dsf.server=test.salesforce.com pages
     
- ###### **permissionset**
  permissionset will fetch all the changes related to **_permission set_** from your org directly in src folder.
  
  > ant -file jenkins_build.xml -Dsf.username=xyz@abc.com.devops -Dsf.password=12345678Ydskalkdjlas -Dsf.server=test.salesforce.com permissionset
     
- ###### **permissionsetgroup**
  permissionsetgroup will fetch all the changes related to **_permission set groups_** from your org directly in src folder.

  > ant -file jenkins_build.xml -Dsf.username=xyz@abc.com.devops -Dsf.password=12345678Ydskalkdjlas -Dsf.server=test.salesforce.com permissionsetgroup

- ###### **profile**
  profile will fetch all the changes related to **_permission set groups_** from your org directly in src folder.
  
  > ant -file jenkins_build.xml -Dsf.username=xyz@abc.com.devops -Dsf.password=12345678Ydskalkdjlas -Dsf.server=test.salesforce.com profile

- ###### **profilePasswordPolicies**
  profilePasswordPolicies will fetch all the changes related to **_profile password policies_** from your org directly in src folder.
  
  > ant -file jenkins_build.xml -Dsf.username=xyz@abc.com.devops -Dsf.password=12345678Ydskalkdjlas -Dsf.server=test.salesforce.com profilePasswordPolicies

- ###### **quickActions**
  quickActions will fetch all the changes related to **_quick actions_** from your org directly in src folder.
  
  > ant -file jenkins_build.xml -Dsf.username=xyz@abc.com.devops -Dsf.password=12345678Ydskalkdjlas -Dsf.server=test.salesforce.com quickActions
     
- ###### **settings**
  settings will fetch all the changes related to **_settings_** from your org directly in src folder.
  
  > ant -file jenkins_build.xml -Dsf.username=xyz@abc.com.devops -Dsf.password=12345678Ydskalkdjlas -Dsf.server=test.salesforce.com settings

- ###### **tabs**
  tabs will fetch all the changes related to **_tabs_** from your org directly in src folder.
  
  > ant -file jenkins_build.xml -Dsf.username=xyz@abc.com.devops -Dsf.password=12345678Ydskalkdjlas -Dsf.server=test.salesforce.com tabs

- ###### **trigger**
  trigger will fetch all the changes related to **_triggers_** from your org directly in src folder.
  
  > ant -file jenkins_build.xml -Dsf.username=xyz@abc.com.devops -Dsf.password=12345678Ydskalkdjlas -Dsf.server=test.salesforce.com trigger

- ###### **workflows**
  workflows will fetch all the changes related to **_workflows_** from your org directly in src folder.
  
  > ant -file jenkins_build.xml -Dsf.username=xyz@abc.com.devops -Dsf.password=12345678Ydskalkdjlas -Dsf.server=test.salesforce.com workflows
     
- ###### **retrieveCodeDifferenceInRepoAndOrg**
  retrieveCodeDifferenceInRepoAndOrg will fetch all the above targets and commit into one branch OrgDiscripencies-{TODAY_DATE} and all the discripencies file will be at build/discripenciesList/log-{TODAY_DATE}
  
  > ant -file jenkins_build.xml -Dsf.username=xyz@abc.com.devops -Dsf.password=12345678Ydskalkdjlas -Dsf.server=test.salesforce.com retrieveCodeDifferenceInRepoAndOrg

### Transformation Commands

#### Profile Transformation 
This command is used to rearrange the profile according to alphabatic order.

> ant -file jenkins_build.xml xslTransformProfile

#### LeadConvertSetting Transformation
This command is used to rearrange the LeadConvertSetting according to alphabatic order.

> ant -file jenkins_build.xml xslTransformLeadConvertSetting

#### All Transformation
This command is used to rearrange the all above targets according to alphabatic order.

> ant -file jenkins_build.xml xslTransformAll

### Sync and Deploy Developer Sandbox Commands

#### Sync dev sandbox with master branch
This command is used to deploy the changes merged in master to the developer sandbox.

> ant -file jenkins_build.xml -Dsf.username=xyz@abc.com.devops -Dsf.password=12345678Ydskalkdjlas -Dsf.server=test.salesforce.com -Dbb.nameBranch=devopsxap SyncCodeWithMasterBranch  
>
> **Note:**  
> - Please create developer branch (nameBranch) only one time with different name and replace devopsxap with that.  
> - Run full deployment only once after creating developer branch and before using this command.  
> - Please perform pre deployment steps mentioned in confluence.

#### Deploy branch code into dev sandbox
This cammand is used to deploy the branch code into developer sandbox.

> ant -file jenkins_build.xml -Dsf.username=xyz@abc.com.devops -Dsf.password=12345678Ydskalkdjlas -Dsf.server=test.salesforce.com -Dbb.nameBranch=devopsxap deployBranch  
>
> **Note:**  
> - Please create developer branch (nameBranch) only one time with different name and replace devopsxap with that.  
> - Run full deployment only once after creating developer branch and before using this command.  
> - Please perform pre deployment steps of that branch mentioned in confluence.