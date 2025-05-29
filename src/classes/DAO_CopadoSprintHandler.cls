/**
 * @author Vlad Tyazhov
 * Apex handler for copado__Sprint__c trigger.
 * Share record with users based on User_Project_Allocation__c records.
 */
public without sharing class DAO_CopadoSprintHandler {
    public class SharingHandler extends DAO_TriggerHandler {
        /**
         * On After Insert - share Sprints with project allocated users
         * @param newList - Trigger.new
         */
        protected override void onAfterInsert(List<SObject> newList) {
            DAOH_UserProjectAllocation.shareToAllocatedUsers((List<copado__Sprint__c>) newList);
        }
    }
}