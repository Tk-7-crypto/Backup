trigger TGR_Competitive_Intelligence_Request on Competitive_Intelligence_Request__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
       fflib_SObjectDomain.triggerHandler(DAO_Competitive_Intelligence_Request.Class);
}