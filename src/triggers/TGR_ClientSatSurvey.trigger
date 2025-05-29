trigger TGR_ClientSatSurvey on Client_Sat_Survey__c (before insert, before update, before delete, 
                                                     after insert, after update, after delete, after undelete) {
    if(!UTL_ExecutionControl.stopTriggerExecution)
        fflib_SObjectDomain.triggerHandler(DAO_ClientSatSurvey.class);
}