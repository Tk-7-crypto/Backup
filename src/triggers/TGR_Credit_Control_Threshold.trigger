trigger TGR_Credit_Control_Threshold on Credit_Control_Threshold__c (before insert, before update, after insert, after update, after undelete, before delete, after delete) {
    fflib_SObjectDomain.triggerHandler(DAO_CreditControlThreshold.class);
}