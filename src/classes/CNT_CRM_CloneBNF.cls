public class CNT_CRM_CloneBNF {
    public String opportunityJSONString{get;private set;}
    public String bnfJSONString{get;private set;}
    public String BNFRecordTypeId{get;private set;}
    public String fieldApiToIdMapJSONString{get;private set;}
    public CNT_CRM_CloneBNF(ApexPages.StandardController stdController) {
        Id currentBNFId  = ApexPages.currentPage().getParameters().get('id');
        BNFRecordTypeId = Schema.SObjectType.BNF2__c.getRecordTypeInfosByName().get('Manual Setup in SAP').getRecordTypeId();
        if(currentBNFId != null){
            BNF2__c bnfRecord = [SELECT Id,Opportunity__c, RecordTypeId FROM BNF2__c where Id =: currentBNFId];
            Id oppId = bnfRecord.Opportunity__c;
            bnfJSONString = JSON.serialize(bnfRecord);
            if(oppId != null) {
                Opportunity opp = [SELECT Id, Name, AccountId, Parent_Opportunity__c, Opportunity_Number__c, LeadSource, Therapy_Area__c, Amount, Type, CurrencyIsoCode,
                                   Contract_Term__c, Contract_Type__c, RecordTypeId, Contract_End_Date__c, Contract_Start_Date__c FROM Opportunity WHERE Id = :oppId];
                opportunityJSONString = JSON.serialize(opp);
            }
        }
        Map<String, String> fieldApiToIdmap = UTL_Sobject.getCustomFieldByIds('BNF2');
        fieldApiToIdMapJSONString = JSON.serialize(fieldApiToIdmap);
        
    }
}