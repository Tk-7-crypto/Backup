/*
 * Version       : 1.0
 * Description   : Apex Controller for Learning Certification component
 */
public with sharing class CNT_PEP_Certifications {
    @AuraEnabled
    public static List<Certification__c> getCert(){
        String uid = UserInfo.getUserId();
        return [SELECT Id,Certification_label__c,Salesforce_User_ID__c,Certified_date__c
                ,LMS_certification_URL__c 
                FROM Certification__c 
                WHERE Salesforce_User_ID__c =: uid];
    }
}