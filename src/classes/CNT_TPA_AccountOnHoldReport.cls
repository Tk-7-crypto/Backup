public with sharing class CNT_TPA_AccountOnHoldReport {
    @AuraEnabled(cacheable = true)
    public static string baseURL(){
        return TPA_Settings__c.getOrgDefaults().Base_Url__c;
    }
    @AuraEnabled(cacheable=true)
    public static List<Account_Compliance__c> getComplianceHoldData(String sortBy){
        String query = 'SELECT id,Name, Account__r.Name, Vendor_TPA_Compliance_Hold_Date__c,Vendor_TPA_Compliance_Hold_Reason__c, Vendor_TPA_Compliance_Hold__c, (SELECT id, Subject, Description FROM Tasks WHERE subject LIKE \'Vendor was on Hold%\' ORDER BY createdDate DESC)  FROM Account_Compliance__c ORDER BY Account__r.Name ' + (sortBy == null ? 'ASC': sortBy);
        return Database.query(query);
    }
}