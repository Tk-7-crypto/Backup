/*
 * Version : 1.0
 * Description : This Apex class is selector layer for LMS Certifications
 */ 
public class SLT_Certification {
    
    public List<Certification__c> selectLMSCertifications(Set<Id> certificationId) {
        return Database.query('SELECT ID,Account__c,Contact__c,Salesforce_User_ID__r.Contact.AccountId,Salesforce_User_ID__r.ContactId FROM Certification__c WHERE Id IN : certificationId');
    }
}