trigger TGR_Product on Product2 (before insert ,before update) {
    if(!UTL_ExecutionControl.stopTriggerExecution)
        fflib_SObjectDomain.triggerHandler(DAO_Product.class);
    
}