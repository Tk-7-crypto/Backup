/**
 * This trigger is used for Project Task Assignment object.
 * version : 1.0
 */
trigger TGR_Project_Task_Assignment on pse__Project_Task_Assignment__c (before insert, before update) {
    fflib_SObjectDomain.triggerHandler(DAO_Project_Task_Assignment.class);
}