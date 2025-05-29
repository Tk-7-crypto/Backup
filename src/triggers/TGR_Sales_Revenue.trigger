trigger TGR_Sales_Revenue on Sales_Revenue__c (before insert) {
    if(!UTL_ExecutionControl.stopTriggerExecution){
        fflib_SObjectDomain.triggerHandler(DAO_Sales_Revenue.class);
    }
}