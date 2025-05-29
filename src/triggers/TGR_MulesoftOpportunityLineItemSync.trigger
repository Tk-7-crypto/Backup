trigger TGR_MulesoftOpportunityLineItemSync on Mulesoft_OpportunityLineItem_Sync__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    fflib_SObjectDomain.triggerHandler(DAO_MulesoftOpportunityLineItemSync.class);
}