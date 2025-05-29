public class CNT_CRM_AllAccountCompetitors {
    
    @AuraEnabled(cacheable=true)
    public static List<Account_Competitor__c> getAccountCompetitors(Id recordId){
        String condition = '(Account__r.ParentId =  \'' + recordId + '\' OR Account__r.Parent.ParentId =  \'' + recordId + '\' ) AND Account__r.RecordTypeId = \'' +CON_CRM.MDM_VALIDATED_ACCOUNT_RECORD_TYPE_ID +'\'';
        Set <String> fieldSet = new Set<String>{'Id', 'Name', 'Account__c', 'Account__r.Name', 'Competitor_Category__c', 'Competitor__c', 'Competitor__r.Name', 'Sub_Offerings__c', 'Pillars__c', 'Contract_Start_Date__c', 'Contract_End_Date__c', 'Active__c'};
            return new SLT_AccountCompetitor().getAccountCompetitors(fieldset, condition);
    }
}