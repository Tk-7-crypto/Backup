/*
 * @author Leo De bruyn <ldebruyn@cldpartners.com>
 * Apex support methods for Assignment Mass Update Lightning Web Component
 */

public with sharing class CNT_PSA_AssignmentMassUpdate {
    public CNT_PSA_AssignmentMassUpdate() {

    }

    @AuraEnabled(cacheable=true)
    public static List<pse__Assignment__c> getAssignmentsByProgram(String programId, List<String> fieldsList){
        return new SLT_Assignment().getAssignmentsByProgram(new Set<Id>{programId}, new Set<String>(fieldsList));
    }

    @AuraEnabled(cacheable=true)
    public static List<pse__Proj__c> getProjectsByProgram(String programId, List<String> fieldsList){
        return new SLT_Project().selectByProgramId(new Set<Id>{programId}, new Set<String>(fieldsList));
    }

    @AuraEnabled(cacheable=true)
    public static List<pse__Proj__c> getServiceLinesByProject(List<Id> projects, List<String> fieldsList){
        return new SLT_Project().selectByParentProjectId(new Set<Id>(projects), new Set<String>(fieldsList));
    }

    @AuraEnabled
    public static String updateAssignmentSchedules(List<Id> scheduleIds, String startDate, String endDate){
        system.debug('Schedule Ids: '+scheduleIds);
        system.debug('Start Date: '+startDate);
        system.debug('End Date: '+endDate);
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                pse__Schedule__c.SObjectType }
        );
        for(Id scheduleId : scheduleIds){
            pse__Schedule__c schedule = new pse__Schedule__c(Id=scheduleId);
            if(startDate != null){
                schedule.pse__Start_Date__c = Date.valueOf(startDate);
            }
            if(endDate != null){
                schedule.pse__End_Date__c = Date.valueOf(endDate);
            }
            system.debug('Preparing to update schedule: '+schedule);
            uow.registerDirty(schedule);
        }
        uow.commitWork();
        system.debug('Updated '+scheduleIds.size()+' schedules.');
        return 'success';
    }
}