/*
 * @author Ratna Paul
 * Apex support methods for Assignment's Schedule's Date Update Lightning Web Component
 */
public with sharing class CNT_PSA_UpdateAssignmentDate {

    @AuraEnabled
    public static String updateAssignmentScheduleDates(Id scheduleId, String startDate, String endDate){
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                pse__Schedule__c.SObjectType }
        );       
        pse__Schedule__c schedule = new pse__Schedule__c(Id=scheduleId);
        if(startDate != null){
            schedule.pse__Start_Date__c = Date.valueOf(startDate);
        }
        if(endDate != null){
            schedule.pse__End_Date__c = Date.valueOf(endDate);
        }
        uow.registerDirty(schedule);
        uow.commitWork();
        return 'success';
    }
}