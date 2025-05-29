trigger TGR_DataPortalQueueUserdetails on CSM_QI_Data_Portal_Queue_User_details__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    fflib_SObjectDomain.triggerHandler(DAO_DataPortalQueueUserdetails.class);
}