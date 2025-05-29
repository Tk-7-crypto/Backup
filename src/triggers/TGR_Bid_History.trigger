/**
* This trigger is used for Bid History object.
* version : 1.0
*/

trigger TGR_Bid_History on Bid_History__c(before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    fflib_SObjectDomain.triggerHandler(DAO_Bid_History.class);
}