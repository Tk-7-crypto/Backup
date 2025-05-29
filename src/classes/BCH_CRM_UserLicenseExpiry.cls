/**
 * Batch to deactivate the user whose License Expiry Date is less than Today
 */ 
public class BCH_CRM_UserLicenseExpiry implements Database.Batchable<Sobject>,Database.Stateful {
    public List<String> error_msg_List;
    public List<String> exception_List;
    public Boolean isValidQuery = true;
    public List<Deactivate_User_Setting__c> userSettingCs;
    public Set<Id> removeLicenceUserId;
    User_Activation_Input_Variables__c userConfig;
    //SFDCDEVOPS-834: removeLicenseOfDeactivatedUser set for storing user ids of users deactivated on the basis of inactivity    
    public Set<Id> removeLicenseOfDeactivatedUser;
    //SFDCDEVOPS-834: packageLicenseExcludedSet for storing Package licenses that should be excluded
    public Set<String> packageLicenseExcludedSet;

    public BCH_CRM_UserLicenseExpiry(){
        error_msg_List = new List<String>();
        exception_List = new List<String>(); 
        removeLicenceUserId = new Set<Id>{};
        userConfig = User_Activation_Input_Variables__c.getValues('BusinessLogic');
        removeLicenseOfDeactivatedUser = new Set<Id>();
        packageLicenseExcludedSet = new Set<String>();
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        Date todayDate = Date.today();
        User_Downgrade_Setting__c userDownCs = User_Downgrade_Setting__c.getInstance();
        Organization org = [SELECT IsSandbox FROM Organization];
        Set<String> userIdSet = new Set<String>();
        
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
        String query = 'SELECT Id, IsActive, License_Expiry_Date__c, FirstName, LastName, EmployeeNumber, Infrequent_User__c, Access_Expiry_Date__c, LastLoginDate FROM User';
        query += ' WHERE isActive = true AND';
        query += ' ((License_Expiry_Date__c < : todayDate) OR';        
        query += ' (Access_Expiry_Date__c < : todayDate AND Infrequent_User__c = true AND LastLoginDate < LAST_N_DAYS:' + Integer.valueOf(userConfig.Days_from_last_login__c) + '))';
        
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

        if(Test.isRunningTest()){
            query += ' LIMIT 1';
        } 
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<User> records) {
        Date todayDate = Date.today();

        if(isValidQuery) {
            for (User user : records) {
                user.IsActive = false;
                if( user.License_Expiry_Date__c < todayDate ) {
                    user.Active_Inactive_Reason__c = 'Termination';
                    //SFDCDEVOPS-834: Set for storing user ids for user who will be terminated
                    removeLicenceUserId.add(user.Id);
                } else if ( user.Access_Expiry_Date__c < todayDate && user.Infrequent_User__c == true && user.LastLoginDate < todayDate - Integer.valueOf(userConfig.Days_from_last_login__c) ) { 
                    user.Active_Inactive_Reason__c = 'Deactivation (Infrequent User)';
                    //SFDCDEVOPS-834: Set for storing user ids for user who will be deactivated 
                    removeLicenseOfDeactivatedUser.add(user.Id);
                }
                else {

                }
                user.Last_Time_Deactivation__c = todayDate;
                //removeLicenceUserId.add(user.Id);
            }
            try {  
                List<Database.SaveResult> SaveResultList = Database.update(records, false);
                for(integer i =0; i<records.size();i++){
                    String msg = '';
                    If(!SaveResultList[i].isSuccess()){
                        msg += records.get(i).firstName+' '+ records.get(i).lastName;
                        msg +=' with License Expiry Date: '+ records.get(i).License_Expiry_Date__c+ ' (SFDC Id: '+ records.get(i).id+' PeopleSoft Id: '+records.get(i).EmployeeNumber+ ' ) ' 
                            +'\n'+'Error: "';        
                        for(Database.Error err: SaveResultList[i].getErrors()){  
                            msg += err.getmessage()+'"\n\n';
                        } 
                        
                    }
                    if(msg!=''){
                        Error_msg_List.add(msg);
                    }
                }
            } catch (Exception exp) {
                String ExceptionMsg ='While deactivating users:-'+'\n';
                for(User u : records){
                    ExceptionMsg += u.firstName + ' ' + u.lastName +'(SFDC Id: ' + u.id + ')' + '\n';
                }
                ExceptionMsg  +='\n Some Exception Occurred As Follows:' + '\n';
                exception_List.add(ExceptionMsg); 
            }
        }
    }

    public void finish(Database.BatchableContext BC){ 
        List<String> toAddresses = new List<String>();
        userSettingCs = new List<Deactivate_User_Setting__c>();
        Set<Id> userIdsList = new Set<Id>();
        if(removeLicenceUserId.size() > 0) {
            removePackageLicence(removeLicenceUserId);
        }
        
        if(removeLicenseOfDeactivatedUser.size() > 0) {
            if(!packageLicenseExcludedSet.isEmpty()) {
                //SFDCDEVOPS-834:Remove all the package licenses except (packageLicenseExcludedSet)
                removePackageLicenseOfDeactivatedUser(removeLicenseOfDeactivatedUser, packageLicenseExcludedSet);
            } else {
                //SFDCDEVOPS-834:If there are no package license to retain, remove all the package licenses
                removePackageLicence(removeLicenseOfDeactivatedUser);
            }
        }
        
        userSettingCs = Deactivate_User_Setting__c.getall().values();
        for(Deactivate_User_Setting__c dus : userSettingCs){
            userIdsList.add(dus.User_Id__c);
        }
        Map<Id, User> usersMap  = new SLT_User().selectByUserId(userIdsList,new Set<String>{'Id','Email'});
        for(Id userId : usersMap.keySet()){
            toAddresses.add(usersMap.get(userId).Email);
        }
        if(Error_msg_List.size()>0){  
            sendMailOnError(Error_msg_List,toAddresses);
        }
        else if(exception_List.size()>0){
            sendMailOnException(exception_List,toAddresses);
        }
    }
    
    public static void removePackageLicence(Set<Id> removeLicenceUserId) {
        List<UserPackageLicense> userPackageLicense = [Select Id, UserId from UserPackageLicense Where UserId IN :removeLicenceUserId ];
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
    public static void removePackageLicenseOfDeactivatedUser(Set<Id> removeLicenseOfDeactivatedUser, Set<String> packageLicenseExcludedSet) {
        List<UserPackageLicense> userPackageLicense = new List<UserPackageLicense>();
        if(!packageLicenseExcludedSet.isEmpty()) {
            userPackageLicense = [Select Id, UserId from UserPackageLicense Where UserId IN :removeLicenseOfDeactivatedUser AND Packagelicense.Namespaceprefix NOT IN:packageLicenseExcludedSet];
        }
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
        String BodyText ;
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        mail.setUseSignature(false);       
        BodyText = '';
        mail.setSubject('Exceptions were thrown while Deactivating Users');                       
        BodyText  +='==============Exception :========\n'; 
        for(String exp : exception_List){              
            BodyText += exp;      
        }               
        mail.setPlainTextBody(BodyText);  
        try{
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        } catch(Exception e) {
            System.debug('Email Failed: ' + e.getMessage());
        }      
        
    }

    public static void sendMailOnError(List<String> Error_msg_List,List<String> toAddresses){
        String BodyText ;
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        mail.setUseSignature(false);          
        mail.setSubject('Error : deactivating '+Error_msg_List.size()+' user(s) with elapsed license expiry dates');            
        BodyText = '';
        BodyText += '***********************************************'+'\n';   
        BodyText += Error_msg_List.size()+' '+'USER(S) COULD NOT BE DEACTIVATED '+'\n';         
        BodyText += '***********************************************'+'\n';
        BodyText += '==  Errors encountered while deactivating users with elapsed license expiry dates  =='+'\n\n';
        for(integer i =0 ; i<Error_msg_List.size();i++ ){   
            BodyText += Error_msg_List.get(i);                
        }  
        BodyText += '===='+'\n\n';
        BodyText +='These errors will keep occuring on a daily basis and will '+
            'prevent the user from being deactivated. These errors are not '+
            'ETL related and need to be resolved in SFDC. Once the issues '+
            'mentioned above have been resolved the user will be automatically deactivated when the batch '+
            'next runs.'+'\n';          
        BodyText += '\n';    
        mail.setPlainTextBody(BodyText);  
        try{
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        } catch(Exception e) {
            System.debug('Email Failed: ' + e.getMessage());
        }
    }
}