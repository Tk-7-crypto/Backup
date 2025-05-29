public with sharing class CNT_Crm_My_Opportunity_View {
    
    @AuraEnabled(cacheable=true)
    public static OpportunityWrapper getOpportunity(){
        OpportunityWrapper opportunityWrapper = new OpportunityWrapper();
        CRM_Config__c crmConfigSetting = CRM_Config__c.getInstance();
        if(crmConfigSetting != null){
            opportunityWrapper.insideSalesUserId = crmConfigSetting.Inside_Sales_User_Id__c;
        }
        Set<String> fieldSet = new Set<String>{'Id', 'Owner.Name', 'OwnerId' , 'AccountId',  'Account.Name', 'Name', 'StageName', 'Amount', 'CloseDate', 'Inside_Sales_Transfer_Date__c', 'CurrencyIsoCode'};
        opportunityWrapper.opportunity = new SLT_Opportunity().getOpportunityWithInsideSalesUser(fieldSet, UserInfo.getUserId());
        //opportunityWrapper.opportunity = [SELECT Id, Owner.Name, Account.Name, Name, StageName, Amount, CloseDate, Inside_Sales_Transfer_Date__c, CurrencyIsoCode From Opportunity Where IsClosed = false AND Inside_Sales__c  = :UserInfo.getUserId()];
        return opportunityWrapper;
    }    
    public class OpportunityWrapper{
        @AuraEnabled
        public List<Opportunity> opportunity;
        
        @AuraEnabled
        public String insideSalesUserId;
    }
}