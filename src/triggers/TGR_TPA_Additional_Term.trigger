trigger TGR_TPA_Additional_Term on TPA_Additional_Term__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) { 
    fflib_SObjectDomain.triggerHandler(DAO_TPA_Additional_Term.class);
}