trigger TGR_MulesoftOpportunitySync on Mulesoft_Opportunity_Sync__c  (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    fflib_SObjectDomain.triggerHandler(DAO_MulesoftOpportunitySync.class);
}