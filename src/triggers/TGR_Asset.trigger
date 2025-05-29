trigger TGR_Asset on Asset (before insert)  {
    if(!UTL_ExecutionControl.stopTriggerExecution)
        fflib_SObjectDomain.triggerHandler(DAO_Asset.class);
    
}