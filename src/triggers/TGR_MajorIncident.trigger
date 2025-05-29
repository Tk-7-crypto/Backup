trigger TGR_MajorIncident on Major_Incident__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    fflib_SObjectDomain.triggerHandler(DAO_MajorIncident.class);
}