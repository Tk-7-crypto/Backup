trigger TGR_InformationOfferingForms on Information_Offering_Forms__c (before insert, after insert, before update, before delete) {
    if(!UTL_ExecutionControl.stopTriggerExecution)
        fflib_SObjectDomain.triggerHandler(DAO_InformationOfferingForms.class);
}