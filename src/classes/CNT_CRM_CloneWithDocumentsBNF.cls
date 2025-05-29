public class CNT_CRM_CloneWithDocumentsBNF {
    
    public String bnfJSONString{get;private set;}
    public String revenueAnalystJSONString{get;private set;}
    public String fieldApiToIdMapJSONString{get;private set;}
    
    public CNT_CRM_CloneWithDocumentsBNF(ApexPages.StandardController stdController) {
        Id currentBNFId  = ApexPages.currentPage().getParameters().get('id');
        if(currentBNFId != null){
            BNF2__c bnfRecord = [SELECT Id,Opportunity__c, RecordTypeId, First_RA__c FROM BNF2__c where Id =: currentBNFId];
            ID vUserId = bnfRecord.First_RA__c;
            system.debug('vUserId : '+vUserId);
            bnfJSONString = JSON.serialize(bnfRecord);
            if(vUserId != null){
                Revenue_Analyst__c ra = [Select Name from Revenue_Analyst__c where id =: vUserId limit 1];                
                revenueAnalystJSONString = JSON.serialize(ra);
            }
            
        }
        Map<String, String> fieldApiToIdmap = UTL_Sobject.getCustomFieldByIds('BNF2');
        fieldApiToIdMapJSONString = JSON.serialize(fieldApiToIdmap);
    }
}