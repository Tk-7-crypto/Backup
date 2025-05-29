trigger TGR_Agreement_Email_Alert on Agreement_Email_Alert__c (before insert, before update) {
    fflib_SObjectDomain.triggerHandler(DAO_Agreement_Email_Alert.Class);
}