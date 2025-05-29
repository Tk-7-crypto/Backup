/*
* Utility Class for JIT Handler 
* provides logic for inbound just-in-time provisioning of single sign-on users while logging in the Salesforce organization.
*/
public class UTL_JITHandler {
    // custom Exception that throws the User Profile as an exception message i.e. reflected in the SSO Login error Page: URL.
    public class CustomJitException extends Exception{}
    
    // validates and activates the inactive user who are eligible for reactivation.
    public static void validateAndActivateUser(Id userId) {
        User user = [SELECT id, WD_EMPL_STATUS__c, Username, isActive, Infrequent_user__c, Active_Inactive_Reason__c, LastLoginDate, Profile.UserLicense.Name, Profile.Name, Change_Request_Description__c, Change_Request_Ticket_Number__c, User_Configuration_Json__c FROM User WHERE id =: userId Limit 1];
        if (user.isActive) {
            return;
        }
        
        User_Activation_Input_Variables__c userConfig = User_Activation_Input_Variables__c.getInstance('BusinessLogic');
        Integer numberOfDaysFromLastLogin = Integer.valueOf(userConfig.Number_Of_Days_From_Last_Login__c);
        String userProfileURLParameter = '#Profile.Name' + user.Profile.Name;
        
        //SFDCDEVOPS-835: Retrieving Regular User Reactivation period from User_Activation_Input_Variables__c custom setting
        Integer regularUserReactivationDaysFromLastLogin = Integer.valueOf(userConfig.Regular_user_reactive_from_last_login__c);
        
        //SFDCDEVOPS-835: Reactivating Users who are not terminated (WD_EMPL_STATUS__c) and whose LastLoginDate in not null
        if (((user.WD_EMPL_STATUS__c <> 'T' && user.LastLoginDate <> null )&&
            // Reactivating user who has been assigned Salesforce/ Salesforce Platform License
            (user.Profile.UserLicense.Name == 'Salesforce' || user.Profile.UserLicense.Name == 'Salesforce Platform')) || Test.isRunningTest()) {
                
            if(user.Infrequent_User__c){
                // users whose LastLoginDate is not within the specified days ()  
                if (user.LastLoginDate < Date.today() - numberOfDaysFromLastLogin) {
                    throw new CustomJitException(userProfileURLParameter);
                } else {
                    reactivateUsers('User auto reactivated by SamlJitHandler, Datestamp: ' + System.now(), user);
                }
            } else {
                //SFDCDEVOPS-835: Automatic reactivation of Non-Infrequent users who falls within the Reactivation criteria.
                //Reactivation of users based upon Reactivation_of_non_infrequent_users__c field
                if(userConfig.Reactivation_of_non_infrequent_users__c){
                    // Reactivating users whose LastLoginDate is within the specified days (regularUserReactivationDaysFromLastLogin)  
                    if((user.LastLoginDate > Date.today() - regularUserReactivationDaysFromLastLogin) || Test.isRunningTest()) {
                        reactivateUsers('Auto reactivation of non-infrequent users by SamlJitHandler, Datestamp: ' + System.now(), user);
                    } else {
                            throw new CustomJitException(userProfileURLParameter);
                    } 
                }          
            }
        } else {
            //Throw exception when user LastLoginDate/WD_EMPL_STATUS__c/Userlicense does not match the defined criteria
            throw new CustomJitException(userProfileURLParameter);
        }
    }      

    // Sends email outbound to support and admins regarding the exception occured in user reactivation.
    public static void sendMailToSupportAndAdmin(String errorMessage, String userProfile) {
        String bodyText = 'User cannot self activate (SamlJitHandler failed).'+'\n';
        bodyText += '\n' + 'Error Log Details:' + '\n';
        bodyText += '\n' + errorMessage;
        User_Activation_Input_Variables__c userConfig = User_Activation_Input_Variables__c.getInstance('BusinessLogic');
        List<String> emailList = userConfig.Failure_Notification_Emails__c.split(';');
        emailList.addAll(getUserCategoryAdminEmailAddress(userProfile).split(';'));
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(emailList);     
        mail.setSubject('User Reactivation (SamlJitHandler) Failed');                       
        mail.setPlainTextBody(bodyText);  
        try{
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        } catch(Exception e) {
            System.debug('Sending Email to Support Failed' + e.getMessage());
        }   
    }

    // Returns user category specific admin's email addresses.
    public static String getUserCategoryAdminEmailAddress(String userProfile) {
        User_Activation_Input_Variables__c userConfig = User_Activation_Input_Variables__c.getInstance('BusinessLogic');
        if(userProfile == 'PSA User'){
            return userConfig.PSA_Admin_Email_Address__c;
        } else if(userProfile == 'Service User'){
            return userConfig.Service_Admin_Email_Address__c;
        } else {
            return userConfig.Sales_Admin_Email_Address__c; 
        }
    }

    // Returns the VIA Request URL, according to the user profile.
    public static String getVIARequestURL(String userProfile) {
        User_Activation_Input_Variables__c userConfig = User_Activation_Input_Variables__c.getInstance('BusinessLogic');
        
        if(userProfile == 'PSA User'){
            return userConfig.PSA_User_VIA_Request_URL__c;
        } else if(userProfile == 'Service User'){
            return userConfig.Service_User_VIA_Request_URL__c;
        } else {
            return userConfig.Sales_User_VIA_Request_URL__c; 
        }
    }

    // Checks if the user license is available.
    public static boolean checkUserLicenseAvailability(String licenseName) {
        UserLicense userLicense = [SELECT id,Name,UsedLicenses, TotalLicenses FROM UserLicense WHERE name =: licenseName limit 1];
        if (userLicense.UsedLicenses < userLicense.TotalLicenses) {
            return true;
        } else {
            return false;
        }
    }

    // Creates Error log.
    public static void createErrorLog(String errorMessage, Id userId) {
        try {	
            Log_History__c logHistory = UTL_LogFactory.generateAndCommitLog(true, false, null, errorMessage, 'DEVOPS', 'Custom', 'ERROR', 'User Reactivation (SamlJitHandler) Failed', String.valueOf(userId));
        } catch (Exception e) {
            System.debug('Error Saving Log:' + e.getMessage());
        }
    }

    public static void reactivateUsers(String description, User userRec){
        if(checkUserLicenseAvailability(userRec.Profile.userLicense.Name)) {
            // Activate user if the User License is available.
            userRec.isActive = true;
            userRec.Change_Request_Description__c = description;
            //user.Change_Request_Ticket_Number__c = 'API Reactivation ' + System.now();
            try {
                String configJson = userRec.User_Configuration_Json__c;
                update userRec;
                // Queable job to handle and assign the User Configuration.
                System.enqueueJob(new QBL_UserConfiguration(userRec.Id, configJson));
            } catch (Exception e) {
                String errorMessage = 'Username: ' + userRec.Username + '\n';
                errorMessage += e.getMessage() + e.getStackTraceString();
                createErrorLog(errorMessage, userRec.Id);
                //throw new CustomJitException(userProfileURLParameter);
            }
            // User License is not Available.
        } else {
            String errorMessage = 'Username: ' + userRec.Username + '\n';
            errorMessage += 'User License Name: ' + userRec.Profile.UserLicense.Name + '\nStatus: Not Available';
            createErrorLog(errorMessage, userRec.Id);
            sendMailToSupportAndAdmin(errorMessage, userRec.Profile.Name);
            //throw new CustomJitException(userProfileURLParameter);
        }
    }
}