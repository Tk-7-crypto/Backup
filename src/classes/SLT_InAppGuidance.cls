/*
 * Version : 1.0
 * Description : This Apex class is selector layer for In_App_Guidance__c Records
 */ 
public class SLT_InAppGuidance {
    
    public In_App_Guidance__c getGuidanceDescription(String pageName, Date dateToday) {
        return Database.query('SELECT Name, Feature_Description__c,Expiration_Date__c FROM In_App_Guidance__c WHERE Name =: pageName AND Expiration_Date__c >: dateToday AND  IsActive__C = true LIMIT 1');
    }
}