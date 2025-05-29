/*
 * Queable Class to handle the User Configuration and notify the 'Infrequent' User and Support team about the
 * User Reactivation Confirmation.
 */
public class QBL_UserConfiguration implements Queueable{
    
    public Id userId;
    // User Configuration i.e. captured on deactivation in JSON format
    public String configJson;
    public QBL_UserConfiguration(Id userId, String configJson) {
        this.userId = userId ;  
        this.configJson = configJson;
    }
    
    public void execute(QueueableContext context) {
                
        if(String.isNotBlank(configJson)) {
			
           	User userRec;
            try {   
                	userRec = [Select id, Name, Username, Email, isActive, Infrequent_User__c, Profile.Name from User where id = :userId];
                
                	Map<Id,UserPackageLicense> userLicenseIdToUserLicenseMap = new Map<Id,UserPackageLicense>();
                    //Map<Id,PermissionSetAssignment> permissionSetIdToPermissionSetMap = new Map<Id,PermissionSetAssignment>();
                    //Map<Id,GroupMember> groupIdToGroupMemberMap = new Map<Id,GroupMember>();
                    //Map<Id,UserTerritory2Association> territoryIdToTerritoryMap = new Map<Id,UserTerritory2Association>();
                    
                    /* Capture User Configuration i.e. Available. */
                    for(UserPackageLicense upl : [select UserId,PackageLicense.AllowedLicenses,PackageLicenseId from UserPackageLicense where UserId = :userId]) {
                        if(!userLicenseIdToUserLicenseMap.containsKey(upl.PackageLicenseId)) {
                            userLicenseIdToUserLicenseMap.put(upl.PackageLicenseId,upl);
                        }
                    }
                    /*
                    for(PermissionSetAssignment psa : [select AssigneeId, PermissionSetId,PermissionSet.name from PermissionSetAssignment where AssigneeId = :userId]) {
                        if(!permissionSetIdToPermissionSetMap.containsKey(psa.PermissionSetId)) {
                            permissionSetIdToPermissionSetMap.put(psa.PermissionSetId,psa);
                        }
                    }
                    for(GroupMember gm : [select UserOrGroupId, GroupId, Group.Name from GroupMember where UserOrGroupId = :userId]) {
                        if(!groupIdToGroupMemberMap.containsKey(gm.GroupId)) {
                            groupIdToGroupMemberMap.put(gm.GroupId,gm);
                        }
                    }
                    for(UserTerritory2Association uta : [select id,Territory2Id, UserId from UserTerritory2Association where UserId = :userId]) {
                        if(!territoryIdToTerritoryMap.containsKey(uta.Territory2Id)) {
                            territoryIdToTerritoryMap.put(uta.Territory2Id,uta);
                        }
                    }
                    */
                    /* Capture User Configuration i.e. Available. */

                    /* Capture Missing User Configuration recorded while deactivation i.e. not Available, to assign to User. */
                    UserConfigWrapper userconfigwrap = (UserConfigWrapper)JSON.deserialize(configJson, UserConfigWrapper.class);
                    
                    List<Id> userLicenseIdList = new List<Id>();
                    List<UserPackageLicense> userPackageLicenseToInsertList = new List<UserPackageLicense>();
                    for(UserPackageLicense upl : userconfigwrap.userlicenseList) {
                        if(!userLicenseIdToUserLicenseMap.containsKey(upl.PackageLicenseId)) {
                            UserPackageLicense userPackageRec= new UserPackageLicense();
                            userPackageRec.PackageLicenseId = upl.PackageLicenseId;
                            userPackageRec.UserId = upl.UserId;
                            userPackageLicenseToInsertList.add(userPackageRec);
                            userLicenseIdList.add(upl.PackageLicenseId);
                        }
                    }
                    
                    /*
                    List<PermissionSetAssignment> permissionSetAssignmentToInsertList = new List<PermissionSetAssignment>();
                    for(PermissionSetAssignment psa : userconfigwrap.permissionSetList) {
                        if(!permissionSetIdToPermissionSetMap.containsKey(psa.PermissionSetId)) {
                            PermissionSetAssignment permissionSetRec= new PermissionSetAssignment();
                            permissionSetRec.PermissionSetId = psa.PermissionSetId;
                            permissionSetRec.AssigneeId = psa.AssigneeId;
                            permissionSetAssignmentToInsertList.add(permissionSetRec);
                        }
                    }
                    
                    List<GroupMember> groupMemberToInsertList = new List<GroupMember>();
                    for(GroupMember gm : userconfigwrap.groupMemberList) {
                        if(!groupIdToGroupMemberMap.containsKey(gm.GroupId)) {
                            GroupMember gmRec= new GroupMember();
                            gmRec.GroupId = gm.GroupId;
                            gmRec.UserOrGroupId = gm.UserOrGroupId;
                            groupMemberToInsertList.add(gmRec);
                        }
                    }
                    
                    List<UserTerritory2Association> userTerritoryToInsertList = new List<UserTerritory2Association>();
                    for(UserTerritory2Association uta : userconfigwrap.territoryList) {
                        if(!territoryIdToTerritoryMap.containsKey(uta.Territory2Id)) {
                            UserTerritory2Association userTerritoryRec= new UserTerritory2Association();
                            userTerritoryRec.Territory2Id = uta.Territory2Id;
                            userTerritoryRec.UserId = uta.UserId;
                            userTerritoryToInsertList.add(userTerritoryRec);
                        }
                    }
                    */
                    /* Capture Missing User Configuration recorded while deactivation i.e. not Available, to assign to User. */

                    /* Check License Availability. */
                    List<PackageLicense> uplList  = [select id, UsedLicenses, AllowedLicenses from PackageLicense where id in :userLicenseIdList AND AllowedLicenses != -1];
                    Boolean licensesAvailable = true;
                    List<String> unavailableLicenses = new List<String>();
                    if(uplList.size() > 0) {
                        for(PackageLicense pl : uplList) {
                            if(pl.UsedLicenses >= pl.AllowedLicenses) {
                                licensesAvailable = false;
                                unavailableLicenses.add(pl.id);
                            }
                        }
                    }
                    /* Check License Availability. */

                    /* Assign Configuration to User. */
                    String insertionExceptionMessage = '';
                    if(licensesAvailable == false) {
                        insertionExceptionMessage += '<br>Package Licenses are not available.<br>';
                        insertionExceptionMessage += unavailableLicenses + '<br>';
                    } else {
                        try {
                            insert userPackageLicenseToInsertList;
                        } catch(Exception e) {
                            insertionExceptionMessage += '<br>' + e.getMessage() + '<br>';
                        }
                    }
                    /*
                    try {
                        insert permissionSetAssignmentToInsertList;
                    } catch(Exception e) {
                        insertionExceptionMessage += '<br>' + e.getMessage() + '<br>';
                    }
                    try {
                        insert groupMemberToInsertList;
                    } catch(Exception e) {
                        insertionExceptionMessage += '<br>' + e.getMessage() + '<br>';
                    }
                    try {
                        insert userTerritoryToInsertList;
                    } catch(Exception e) {
                        insertionExceptionMessage += '<br>' + e.getMessage();
                    }
                    */
                    /* Assign Configuration to User. */
					
                	// Create Error Log and send Email to user and support in case of any exception(s) while applying user configuration.
                    if(String.isNotBlank(insertionExceptionMessage)) {
                        createErrorLog(insertionExceptionMessage, userRec.Id);
                        String subject = 'User Reactivation (SamlJitHandler) - Queueable Job Failed.';
                        String bodyText = 'User configuration cannot be applied after activation (Queueable Job failed).'+'<br><br>';
                        bodyText += 'Username: ' + userRec.Username;
                        bodyText += '<br>' + 'Error Log Details:' + '<br>';
                        bodyText += insertionExceptionMessage;
                        sendFailureMailToSupport(userRec.Id, userRec.Profile.Name, subject, bodyText);
                        notifyUser(userRec.Id, userRec.Name, insertionExceptionMessage, userRec.Profile.Name);
                    }
                 
            // Create Error Log and send Email to user and support in case of any other exception.
            } catch(Exception e) {
                createErrorLog(e.getMessage() + '\n' + e.getStackTraceString() + '\n' + e, userId);
                String subject = 'User Reactivation (SamlJitHandler) - Queueable Job Failed.';
                String bodyText = '<br>' + 'User configuration cannot be applied after activation (Queueable Job failed)' + '<br>';
                bodyText += 'Username: ' + userRec.Username;
                bodyText += '<br>' + 'Error Log Details:' + '<br>';
                bodyText += '<br>' + e.getMessage() + '<br>' + e.getStackTraceString() + '<br>' + e;
                sendFailureMailToSupport(userRec.Id, userRec.Profile.Name, subject, bodyText);
                //notifyUser(userRec.Id, userRec.Name, e.getMessage(), userRec.Profile.Name);                
            }
        // User has no configuration stored.
        } else {
            createErrorLog('User Configuration Not Found.', userId);
        }
    }

	// Send Email to the user with details in case of any failure while applying configuration   
    @future
    public static void notifyUser(Id userId, String userName, String exceptionMessage, String userProfile) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String subject = 'System issue with your salesforce access. VIA request required.';
        String bodyText = 'Dear ' + userName  + ',<br><br>';
        bodyText += 'The issue below has been detected on your Salesforce account.' + '<br>';
        bodyText += 'Please create a VIA request to address the issue with Salesforce Support Team.' + '<br><br>';
        bodyText += '<a href="'+ UTL_JITHandler.getVIARequestURL(userProfile) + '">Click Here</a>';
        bodyText += ' to launch VIA request. Please include the error details below to the VIA request.' + '<br><br>';
        bodyText += 'Error Details: ' + '<br>';
        bodyText += exceptionMessage + '<br>';
        bodyText += 'Regards,' + '<br>';
        bodyText += 'Salesforce Support Team';    
        
        mail.setSubject(subject);                       
        mail.setHtmlBody(bodyText);
        mail.setTargetObjectId(userId);
        mail.setSaveAsActivity(false);
        try{
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        } catch(Exception e) {
            System.debug('Sending Email to User Failed' + e.getMessage());
        }
    }

    // Send Email to the support team and the module admin with details in case of any failure while applying user configuration.
    @future
    public static void sendFailureMailToSupport(Id userId, String userProfile, String subject, String description) {
        String bodyText = '';
        bodyText += description;
        User_Activation_Input_Variables__c userConfig = User_Activation_Input_Variables__c.getInstance('BusinessLogic');
        List<String> emailList = userConfig.Failure_Notification_Emails__c.split(';');
        emailList.addAll(UTL_JITHandler.getUserCategoryAdminEmailAddress(userProfile).split(';'));
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(emailList);     
        mail.setSubject(subject);                       
        mail.setHtmlBody(bodyText);
        try{
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        } catch(Exception e) {
            System.debug('Sending Email to Support Failed' + e.getMessage());
        }
    }

    public static void createErrorLog(String errorMessage, Id userId) {
        try {	
            Log_History__c logHistory = UTL_LogFactory.generateAndCommitLog(true, false, null, errorMessage, 'DEVOPS', 'Custom', 'ERROR', 'User Reactivation (SamlJitHandler) - Queueable Job Failed.', String.valueOf(userId));
        } catch (Exception e) {
            System.debug('Error Saving Log:' + e.getMessage());
        }
    }

}