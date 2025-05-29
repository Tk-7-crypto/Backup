trigger TGR_TpaOffNotificationAccountMap on TPA_Off_Notification_Account_Mapping__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    fflib_SObjectDomain.triggerHandler(DAO_TpaOffNotificationAccountMap.class);
    
}