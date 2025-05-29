/**
* Batch to deactivate the Users
*/ 
public class BCH_CRM_DowngradeUserLicence implements Database.Batchable<Sobject>,Database.Stateful {
    public List<String> errorMsgList;
    public List<String> exceptionList;
    public Boolean isValidQuery = true;
    public Set<Id> removeLicenceUserId;
    //SFDCDEVOPS-834: packageLicenseExcludedSet for storing Package licenses that should be excluded.   
    public Set<String> packageLicenseExcludedSet;
    public BCH_CRM_DowngradeUserLicence(){
        errorMsgList = new List<String>();
        exceptionList = new List<String>(); 
        removeLicenceUserId = new Set<Id>();
        packageLicenseExcludedSet = new Set<String>();
    }
    public Database.QueryLocator start(Database.BatchableContext context) {
        Set<String> profileIdExcludedSet = new Set<String>();
        Set<String> userLicenceIncludedSet = new Set<String>();
        Set<String> userIdSet = new Set<String>();
        User_Downgrade_Setting__c userDownCs = User_Downgrade_Setting__c.getInstance();
        Organization org = [SELECT IsSandbox FROM Organization];
        String query = 'SELECT Id, Name, firstName, lastName, EmployeeNumber, Profile.Name, User_License_Type__c, IsActive FROM User WHERE';
        query += ' IsActive = true AND Is_Excluded_From_Deactivation_Process__c = false';

        //SFDCDEVOPS-834 Adding Package Licenses to set through Custom Metadata that should be excluded
        Map<String, Package_License_Configuration__mdt> packageLicenseMd = Package_License_Configuration__mdt.getAll();
        if(packageLicenseMd != null) {
            for(String packageLicenseRec : packageLicenseMd.keySet()) {
                Boolean retainLicense = packageLicenseMd.get(packageLicenseRec).Retain_License__c;
                if(retainLicense) {
                    packageLicenseExcludedSet.add(packageLicenseMd.get(packageLicenseRec).Package_License_Name__c);
                }
            }
        }
        if (userDownCs != null) {
            if (userDownCs.Profile_ID_to_be_excluded__c != null) {
                profileIdExcludedSet.addAll((userDownCs.Profile_ID_to_be_excluded__c).split(','));
            }
            if (userDownCs.User_License_type_to_be_Included__c != null) {
                userLicenceIncludedSet.addAll((userDownCs.User_License_type_to_be_Included__c).split(','));
            }
            if(userDownCs.Activation_Date_Duration_in_Days__c != null && userDownCs.Last_Login_Duration_in_Days__c != null) {
                query += ' AND ProfileId NOT IN :profileIdExcludedSet AND User_License_Type__c IN :userLicenceIncludedSet';
                query += ' AND (Activation_Date__c < LAST_N_DAYS:'+ Integer.valueOf(userDownCs.Activation_Date_Duration_in_Days__c) + ')';
                query += ' AND (LastLoginDate < LAST_N_DAYS:' + Integer.valueOf(userDownCs.Last_Login_Duration_in_Days__c) + ' OR LastLoginDate = null)';
            } else {
                isValidQuery = false;
            }
            if (org.IsSandbox || Test.isRunningTest()) {
                if (userDownCs.OrgId__c == null) {
                    if (userDownCs.User_Ids__c != null) {
                        userIdSet.addAll((userDownCs.User_Ids__c).split(','));
                        query += ' AND Id IN :userIdSet';
                    } else {
                        isValidQuery = false;
                    }
                } else {
                    if(userDownCs.OrgId__c != UserInfo.getOrganizationId()){
                        isValidQuery = false;
                    }
                }
            }
        } else {
            isValidQuery = false;
        }
        if(Test.isRunningTest() || !isValidQuery){
            query += ' LIMIT 1';
        }
        System.debug(query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<User> records) {
        User_Activation_Input_Variables__c userConfig = User_Activation_Input_Variables__c.getValues('BusinessLogic');
        integer allowedReactivation = Integer.valueOf(userConfig.Allowed_Reactivation__c);
        
        // Set of users, who can be marked as Infrequent users.
        Set<Id> infrequentsUsers = new Set<Id>(New Map<Id, AggregateResult>([SELECT User__r.id, count(id) FROM User_Audit_Log__c WHERE User__c IN : records AND Field_Name__c = 'IsActive' AND New_Value__c = 'true' GROUP BY User__r.id HAVING COUNT(id) > : allowedReactivation]).keySet());

        if (isValidQuery) {
            for (User user : records) {
                user.IsActive = false;
                user.Active_Inactive_Reason__c = 'Deactivation (Inactivity)';
                // Need to be revised*.
                if(infrequentsUsers.contains(user.id)) {
                    user.Infrequent_User__c = true;
                }
                removeLicenceUserId.add(user.Id);
            }
            try {  
                List<Database.SaveResult> saveResultList = Database.update(records, false);
                for(integer i =0; i<records.size();i++){
                    String msg = '';
                    If(!saveResultList[i].isSuccess()){
                        msg += records.get(i).firstName+' '+records.get(i).lastName;
                        msg +=' (SFDC Id: '+ records.get(i).id+' Employee Number '+records.get(i).EmployeeNumber+ ' ) ' 
                            +'\n'+'Error: "';        
                        for(Database.Error err: SaveResultList[i].getErrors()){  
                            msg += err.getmessage()+'"\n\n';
                        }
                    }
                    if(msg!='')
                        errorMsgList.add(msg);
                }
            } catch (Exception exp) {
                String exceptionMsg ='While deactivating users:-'+'\n';
                for(User u : records){
                    exceptionMsg += u.firstName+' '+u.lastName+'(SFDC Id: '+u.id+')'+'\n';
                }
                exceptionMsg  +='\n Some Exception Occurred As Follows:'+'\n';
                exceptionList.add(ExceptionMsg); 
            }
        }
    }
    
    public void finish(Database.BatchableContext BC){
        List<String> toAddresses = new List<String>();
        User_Downgrade_Setting__c userDownCs = User_Downgrade_Setting__c.getInstance();
        Set<String> notificationEmailSet = new Set<String>();
         //SFDCDEVOPS-834:Calling this method for removing package license after user deactivation
        if(removeLicenceUserId.size() > 0) {
            if(!packageLicenseExcludedSet.isEmpty()) {
                removePackageLicenseOfDeactivatedUser(removeLicenceUserId, packageLicenseExcludedSet);
            }
            else {
                removePackageLicence(removeLicenceUserId);
            }
        }

        if (userDownCs != null) {
            if (userDownCs.Notification_emails__c != null) {
                notificationEmailSet.addAll((userDownCs.Notification_emails__c).split(','));
                for(String email : notificationEmailSet){
                    toAddresses.add(email);
                }
                if (isValidQuery) {
                    if(errorMsgList.size()>0){  
                        sendMailOnError(errorMsgList, toAddresses);
                    }
                    else if(exceptionList.size()>0){
                        sendMailOnException(exceptionList, toAddresses);
                    }
                } else {
                    String exceptionMsg ='While deactivating users:- Custom Setting (User Downgrade Setting) data is corrupted.'+'\n';
                    exceptionList.add(ExceptionMsg);
                    sendMailOnException(exceptionList, toAddresses);
                }       
            }
        }
    }
    
    public static void removePackageLicence(Set<Id> removeLicenceUserId){
        List<UserPackageLicense> userPackageLicense = [Select Id, UserId from UserPackageLicense Where UserId IN :removeLicenceUserId];
        List<UserPackageLicense> updatePakage = new List<UserPackageLicense>();
        if(userPackageLicense.size() > 0) {
            for(UserPackageLicense userLic : userPackageLicense) {
                updatePakage.add(userLic);
            }
        }
        
        if(updatePakage.size() > 0) {   
            delete updatePakage;
        }
    }

    //SFDCDEVOPS-834 : Method defined for removing package licenses for deactivated users excluding (packageLicenseExcludedSet)
    public static void removePackageLicenseOfDeactivatedUser(Set<Id> removeLicenceUserId, Set<String> packageLicenseExcludedSet){
        //SFDCDEVOPS-834: Retrieve the UserPackageLicense records to be revoked from user excluding (packageLicenseExcludedSet).
        List<UserPackageLicense> userPackageLicense = [Select Id, UserId from UserPackageLicense Where UserId IN :removeLicenceUserId AND Packagelicense.Namespaceprefix NOT IN:packageLicenseExcludedSet];
        List<UserPackageLicense> updatePakage = new List<UserPackageLicense>();
        if(userPackageLicense.size() > 0) {
            for(UserPackageLicense userLic : userPackageLicense) {
                updatePakage.add(userLic);
            }
        }
        
        if(updatePakage.size() > 0) {    
            delete updatePakage;
        }
    }

    
    public static void sendMailOnException(List<String> exception_List,List<String> toAddresses){
        String bodyText = '';
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);     
        mail.setSubject('Exceptions were thrown while Deactivating Users');                       
        bodyText  +='==============Exception========\n'; 
        for(String exp : exception_List){              
            bodyText += exp;      
        }               
        mail.setPlainTextBody(bodyText);  
        try{
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        } catch(Exception e) {
            System.debug('Email Failed: ' + e.getMessage());
        }          
    }
    
    public static void sendMailOnError(List<String> Error_msg_List,List<String> toAddresses){
        String bodyText ;
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);       
        mail.setSubject('Error : Deactivating '+Error_msg_List.size()+' user(s) who are not logged in for specified number of days.');            
        bodyText = '';
        bodyText += '***********************************************'+'\n';   
        bodyText += Error_msg_List.size()+' '+'USER(S) COULD NOT BE DEACTIVATED '+'\n';         
        bodyText += '***********************************************'+'\n';
        bodyText += '==  Errors encountered while deactivating users who are not logged in for specified number of days.  =='+'\n\n';
        for(integer i =0 ; i<Error_msg_List.size();i++ ){   
            bodyText += i+1 + '.';
            bodyText += Error_msg_List.get(i) + '\n';                
        }  
        mail.setPlainTextBody(BodyText);  
        try{
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        } catch(Exception e) {
            System.debug('Email Failed: ' + e.getMessage());
        }                 
    }
}