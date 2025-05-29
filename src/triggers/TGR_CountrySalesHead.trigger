trigger TGR_CountrySalesHead on Country_Sales_Head__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    If(!UTL_ExecutionControl.stopTriggerExecution)
        fflib_SObjectDomain.triggerHandler(DAO_CountrySalesHead.class);
}