/**
 * @author Vlad Tyazhov
 * Apex handler for copado__User_Story__c trigger.
 * Share record with users based on User_Project_Allocation__c records.
 */
public without sharing class DAO_CopadoUserStoryHandler {
    public class SharingHandler extends DAO_TriggerHandler {
        /**
         * On After Insert - share User Story with project allocated users.
         * @param newList - Trigger.new
         */
        protected override void onAfterInsert(List<SObject> newList) {
            DAOH_UserProjectAllocation.shareToAllocatedUsers((List<copado__User_Story__c>) newList);
        }

        /**
         * If UserStory.Project changed - remove sharing from old project users and create sharing for new.
         * @param newList - Trigger.new
         * @param oldMap - Trigger.oldMap
         */
        protected override void onAfterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            DAOH_UserProjectAllocation.updateSharingOnProjectChange(newList, (Map<Id, copado__User_Story__c>) oldMap);
        }
    }
}