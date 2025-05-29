trigger TGR_Agency_Program on Agency_Program__c (before insert, before update, before delete, after insert, after update) {
    fflib_SObjectDomain.triggerHandler(DAO_Agency_Program.class);
}