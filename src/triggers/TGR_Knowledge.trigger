trigger TGR_Knowledge on Knowledge__kav (before insert,before update,after insert, after update) {  
    CSM_case_Trigger_Handler__c triggerControlSetting = CSM_case_Trigger_Handler__c.getInstance();
    if(!UTL_ExecutionControl.stopTriggerExecution && triggerControlSetting != null && !triggerControlSetting.Disable_KB_Trigger__c)
        fflib_SObjectDomain.triggerHandler(DAO_Knowledge.class);

}