public class CNT_CRM_UpadateCloseDate {
    
    /**
     * This method returns Opportunity line Item with Schedule Records for any opportunity.
     * @params  Id opportinityId
     * @params  List<String> olifieldList
     * @params  List<String> olifieldList
     * @return  List<OpportunityLineItem> opportunityLineItemList
     */
    @AuraEnabled
    public static List<OpportunityLineItem> getOliByIdWithSchedule(Id opportinityId, List<String> olifieldList, List<String> oliSchedulefieldList) {
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        try {
            oliList = SRV_CRM_OpportunityLineItem.getOliByIdWithSchedule(new Set<Id>{opportinityId},new Set<String>(olifieldList), new Set<String>(oliSchedulefieldList));
        } catch(Exception ex) {
            throw new AuraHandledException(JSON.serialize(ex));
        }
        return oliList;
    }
    
    /**
     * This method returns Opportunity Record.
     * @params  Id opportinityId
     * @return  List<Opportunity>
     */
    @AuraEnabled
    public static List<Opportunity> getOpportunityRecord(Id opportinityId) {
        List<Opportunity> oppList = new List<Opportunity>();
        Map<Id, Opportunity> idToOpportunityMap = null;
        Set<String> oppFieldList = new Set<String>{'id','Name','CurrencyIsoCode','CloseDate','Gross_Q1_Value__c','Gross_Q2_Value__c','Gross_Q3_Value__c','Gross_Q4_Value__c','Gross_Q1_NY_Value__c','Gross_Q2_NY_Value__c','Gross_Q3_NY_Value__c','Gross_Q4_NY_Value__c'};
        try {
            idToOpportunityMap = SRV_CRM_Opportunity.getOppDetail(new Set<Id>{opportinityId}, oppFieldList);
            oppList.add(idToOpportunityMap.get(opportinityId));
        } catch(Exception ex) {
            throw new AuraHandledException(JSON.serialize(ex));
        }
        return oppList;
    }
    
     /**
     * This method is to update the Modified Opportunity Close Date and schedules. 
     * @params  Id opportinityId
     * @params  String dayMoved 
     * @params  Boolean isToUpdateSchedule 
     * @params  List<String> olifieldList 
     * @params  List<String> oliSchedulefieldList 
     */
    @AuraEnabled
    public static void updateCloseDateOfOpportunity(Id opportinityId, String dayMoved, Boolean isToUpdateSchedule,List<String> olifieldList, List<String> oliSchedulefieldList) {
        try {
            Integer dayMove = Integer.valueOf(dayMoved);
            SRV_CRM_Opportunity.updateCloseDateOfOpportunity(opportinityId, dayMove, isToUpdateSchedule, olifieldList, oliSchedulefieldList);
        } catch(Exception ex) {
            throw new AuraHandledException(JSON.serialize(ex));
        }    
    }
}