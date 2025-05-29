/**
 * This trigger is used for SWAT_Intake__c object.
 * version : 1.0
 */
trigger TGR_SWAT_Intake on SWAT_Intake__c (before insert,before update,after insert,after update) {
    if(!UTL_ExecutionControl.stopTriggerExecution)
	fflib_SObjectDomain.triggerHandler(DAO_SWAT_Intake.class);
}