/*
* Version       : 1.1
* Description   : Apex Utility class for IQVIA. 
*/
public class UTL_GLOBAL {
    
    private static Double currentReleaseVersion;
    private static Double crmConfingReleaseVersion;
    private static UTL_GLOBAL classInstance = null;
    private static Map<Id, User> userMap = new Map<Id, User>();
    private static Map<Id, CurrencyType> currencyMap = new Map<Id, CurrencyType>();
    private static Map<Id, Profile> profileMap = new Map<Id, Profile>();
    
    /**
    * This function will return current release version.
    */
    public static Double getCurrentReleaseVersion() {
        if(currentReleaseVersion == null) {
            if(Test.isRunningTest()) {
                currentReleaseVersion = 3000.12; 
            } else {
                Current_Release_Version__c releaseVersionSetting = Current_Release_Version__c.getInstance();
                if(releaseVersionSetting.Current_Release__c != null) {
                    currentReleaseVersion = Double.valueOf(releaseVersionSetting.Current_Release__c);
                }
            }
        }
        return currentReleaseVersion; 
    }
    
    /**
    * This function will return map of User with minimum number of query in a transaction.
    */
    public static Map<Id, User> getUserWithProfile(Set<Id> Ids) {
        Set<Id> idsToQuery = new Set<Id>();
        List<User> userDetailByIds;
        for(Id key: Ids) {
            if(!userMap.containsKey(key)) {
                idsToQuery.add(key);
            }   
        }
        if(!idsToQuery.isEmpty()) {
            userDetailByIds = new SLT_user().getUserDetailByIds(null, idsToQuery);
            for(User userObj : userDetailByIds) {
                userMap.put(userObj.Id, userObj);
            }
        }
        return userMap;
    }
    
    /**
    * This function will return map of all CurrencyType with minimum number of query in a transaction.
    */
    public static Map<Id, CurrencyType> getCurrencyType() {
        if(currencyMap.isEmpty()) {
            currencyMap = new SLT_CurrencyType().selectAllCurrencyType();
        }
        return currencyMap;
    }
    
    /**
    * This function will return map of Profile with minimum number of query in a transaction.
    */
    public static Map<Id, Profile> getProfile(Set<Id> idSet) {
        Set<Id> idSetToQuery = new Set<Id>();
        List<Profile> profileList;
        for(Id key: idSet) {
            if(!profileMap.containsKey(key)) {
                idSetToQuery.add(key);
            }
        }
        if(!idSetToQuery.isEmpty()) {
            profileList = new SLT_Profile().selectById(idSetToQuery);
            for(Profile profileObj: profileList) {
                profileMap.put(profileObj.Id, profileObj);
            }
        }
        return profileMap;
    }
    
    /**
    * This function will return current release version from CRM Config Custom Setting.
    */
    public static Double getCrmConfigReleaseVersion() {
        CRM_Config__c releaseVersion = CRM_Config__c.getInstance();
        if(Test.isRunningTest()) {
            crmConfingReleaseVersion = 2021.05; 
        } else {
            if(releaseVersion.Current_Release__c != null) {
            	crmConfingReleaseVersion = Double.valueOf(releaseVersion.Current_Release__c);
            }
        } 
        return crmConfingReleaseVersion; 
    }

	/**
    * This method is used to concatenate several messages for an exception 
    * @param Exception exceptionThrown 
    * @return String 
    */ 
    public static String concatenateException(Exception exceptionThrown) {
        String result = null;
        if(exceptionThrown != null) {
            String lineNumber = String.valueOf(exceptionThrown.getLineNumber());
            String message = exceptionThrown.getMessage();     
            String stackTrace = exceptionThrown.getStackTraceString();
            String typeOfException = exceptionThrown.getTypeName();
            result = lineNumber + ' ' + message + ' ' + stackTrace + ' ' + typeOfException;   
        }    
        return result; 
    }
    
    /**
    * This method is used to send email 
    * @param List<String> toAddresses
    * @param String subject
    * @param String body
    */
    public static void sendEmail(List<String> toAddresses, String subject, String body) {
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        
        Messaging.SingleEmailMessage mail= new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        mail.setSubject(subject); 
        mail.setPlainTextBody(body);  
        mail.setSaveAsActivity(false);
        emailList.add(mail);
        Messaging.sendEmail(emailList);
    }
}
