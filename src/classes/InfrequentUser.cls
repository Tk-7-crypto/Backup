/*
 * Apex Class to handle REST API Calls from the Sharepoint Page to validate and activate the
 * 'Infrequent' user(s).
 * version : 1.0
 */
@RestResource(urlMapping='/UserAccess/*')
global with sharing class InfrequentUser {
    
    // Method to handle the Get request sent through the external server to validate an user for reactivation.
    @HttpGet
    global static String validateUser()  {      
       	
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String userName = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1) + '@%';
        List<User> result = [SELECT Id, Active_Inactive_Reason__c, Infrequent_User__c, Profile.UserLicense.Name, Profile.PermissionsApiUserOnly, Profile.Name, Name, Username, EmployeeNumber, isActive, LastLoginDate FROM User WHERE Username like :userName];
        System.debug(userName);
        JsonReturnWrapper wrap = new JsonReturnWrapper();
        User_Activation_Input_Variables__c userConfig = User_Activation_Input_Variables__c.getInstance('BusinessLogic');
        Map<string,User_Activation_API_Response__c> apiResponse = User_Activation_API_Response__c.getAll();
            
        if(result.size() == 0) {
            wrap.code = 21; 
            wrap.message = apiResponse.get('21').Response_Message__c;
            return JSON.serialize(wrap,true);
        } else {
            if(result.size() > 1) {
                wrap.code = 22;
                wrap.message = apiResponse.get('22').Response_Message__c;
                return JSON.serialize(wrap,true);
            } else {
                if(result.size() == 1) {
                    Integer numberOfDaysFromLastLogin = Integer.valueOf(userConfig.Number_Of_Days_From_Last_Login__c);
                    if(result[0].isActive) {
                        wrap.code = 23;
                        wrap.message = 'Username:' + result[0].username + '<br>Employee Number: ' + result[0].EmployeeNumber + '<br>' + apiResponse.get('23').Response_Message__c;
                        return JSON.serialize(wrap,true);
                    } 
                    else if (!result[0].Infrequent_User__c){
                        wrap.code = 24;
                        wrap.message = 'Username:' + result[0].username + '<br>Employee Number: ' + result[0].EmployeeNumber + '<br>' + apiResponse.get('24').Response_Message__c;
                        return JSON.serialize(wrap,true);
                    }
                    else if (result[0].LastLoginDate < Date.today() - numberOfDaysFromLastLogin){
                        wrap.code = 25; 
                        wrap.message = 'Username:' + result[0].username + '<br>Employee Number: ' + result[0].EmployeeNumber + '<br>Last Login Date:' + result[0].LastLoginDate+'<br>' + apiResponse.get('25').Response_Message__c;
                        return JSON.serialize(wrap,true);
                    }
                    else {
                        if((result[0].Active_Inactive_Reason__c == 'Deactivation (Inactivity)' || result[0].Active_Inactive_Reason__c == 'Other (Manual Deactivation)'|| result[0].Active_Inactive_Reason__c == 'Deactivation (Infrequent User)')
                        && (result[0].Profile.UserLicense.Name == 'Salesforce' || result[0].Profile.UserLicense.Name == 'Salesforce Platform')) {
                            wrap.code = 10;
                            wrap.message = 'Username:' + result[0].username + '<br>Employee Number: ' + result[0].EmployeeNumber + '<br>Last Login Date:' + result[0].LastLoginDate + '<br>' + apiResponse.get('10').Response_Message__c;
                            wrap.id = result[0].Id;
                            return JSON.serialize(wrap,true);
                        } else {
                            wrap.code = 20;
                            wrap.message = apiResponse.get('20').Response_Message__c;
                            return JSON.serialize(wrap,true);
                        }
                    }
                } else {
                    wrap.code = 20;
                    wrap.message = apiResponse.get('20').Response_Message__c;
                    return JSON.serialize(wrap,true);
                }
            }
        }
    }
    
    // Method to handle the Post request sent through the external server to reactivate the validated user.
    @HttpPost
    global static String activateUser(String userId) {
        Map<string,User_Activation_API_Response__c> apiResponse = User_Activation_API_Response__c.getAll();
        User_Activation_Input_Variables__c userConfig = User_Activation_Input_Variables__c.getValues('BusinessLogic');        JsonReturnWrapper wrap = new JsonReturnWrapper();
        User result = [SELECT Id, username, isActive, Infrequent_User__c, User_Configuration_Json__c, Access_Expiry_Date__c, Active_Inactive_Reason__c, EmployeeNumber FROM User WHERE Id = :userId ];
        if(result != NULL) {
            if(!result.isActive && result.Infrequent_User__c) {
                result.isActive = true;
                result.Change_Request_Description__c = 'API Reactivation ' + System.now();
                result.Change_Request_Ticket_Number__c = 'API Reactivation ' + System.now();
                result.Active_Inactive_Reason__c = 'Reactivation';
            } else { 
                wrap.code = 40;
                wrap.message = apiResponse.get('40').Response_Message__c;
                return Json.serialize(wrap, true);
            }
        } 
        try {
            update result;
            // Queable job to handle the User Configuration and notify the User/Support on reactivation confirmation.
            ID jobID = System.enqueueJob(new QBL_UserConfiguration(userId,result.User_Configuration_Json__c));
            System.debug('jobID'+jobID);
            wrap.code = 30;
            wrap.message = 'Username:' + result.username + '<br>Employee Number: ' + result.EmployeeNumber + '<br>'+ apiResponse.get('30').Response_Message__c;
            return Json.serialize(wrap, true);
        } catch(Exception e) {
            System.debug(e + e.getMessage() + e.getStackTraceString());
            wrap.code = 40;
            wrap.message = 'Username:' + result.username + '<br>Employee Number: ' + result.EmployeeNumber + '<br>' + apiResponse.get('40').Response_Message__c + '<br>' + 'Exception Message:' + e.getMessage();
            return Json.serialize(wrap, true);
        }   
    }

    public class JsonReturnWrapper {
        public Integer code;
        public String message;
        public Id id;
    }
}