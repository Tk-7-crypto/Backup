/*
* Author		: 
* Purpose		: Trigger on Revenue_Analyst__c Object
*/
trigger TGR_Revenue_Analyst on Revenue_Analyst__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    fflib_SObjectDomain.triggerHandler(DAO_Revenue_Analyst.class);
}