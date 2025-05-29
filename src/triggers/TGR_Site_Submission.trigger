/**
 * Author : Ronak Mehta
 * Created Date : 08-11-2024
 * This trigger is used for Site_Submission__c object.
 **/
trigger TGR_Site_Submission on Site_Submission__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if(!UTL_ExecutionControl.stopTriggerExecution)
        fflib_SObjectDomain.triggerHandler(DAO_Site_Submission.class);
}