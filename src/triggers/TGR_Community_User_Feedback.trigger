trigger TGR_Community_User_Feedback on Community_User_Feedback__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if(!UTL_ExecutionControl.stopTriggerExecution)
    fflib_SObjectDomain.triggerHandler(DAO_Community_User_Feedback.class);
}