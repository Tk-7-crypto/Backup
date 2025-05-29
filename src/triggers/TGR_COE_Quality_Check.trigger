/**
* This trigger is used for CSM_QI_Tech_COE_QualityCheck__c object.
* version : 1.0
*/
trigger TGR_COE_Quality_Check on CSM_QI_Tech_COE_QualityCheck__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    fflib_SObjectDomain.triggerHandler(DAO_COE_Quality_Check.class);
}