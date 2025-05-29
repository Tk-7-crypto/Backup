public class DAOH_Certification {
    
    public static void updateCertificationAccount(List<Certification__c> newList) {        
        Set<Id> certificationId = new Set<Id>();
        for(Certification__c cert : newList)
        {
            certificationId.add(cert.Id);
        }
        List<Certification__c> certList = new List<Certification__c>();
        certList = new SLT_Certification().selectLMSCertifications(certificationId);
        
        for(Certification__c cert : certList)
        {
            cert.Account__c = cert.Salesforce_User_ID__r.Contact.AccountId;
            cert.Contact__c = cert.Salesforce_User_ID__r.ContactId;
        }
        
        update certList;
    }

}