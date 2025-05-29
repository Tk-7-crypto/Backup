trigger TGR_DrugProductName on Drug_Product_Name__c (before insert, after insert, after delete) {
    if(!UTL_ExecutionControl.stopTriggerExecution)
        fflib_SObjectDomain.triggerHandler(DAO_DrugProductName.class);
}