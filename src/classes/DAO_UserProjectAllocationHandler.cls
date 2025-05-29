/**
 * @author Vlad Tyazhov
 * Apex handler for User_Project_Allocation__c trigger.
 * Before insert/update - perform validation.
 * After insert/update/delete - share Copado Project-related records (User Stories, Sprints, Promotions).
 */
public without sharing class DAO_UserProjectAllocationHandler {
    public class SharingHandler extends DAO_TriggerHandler {
        /**
         * On before insert - validate that there is no other Allocation with this Project-User pair.
         * @param newList - Trigger.new
         */
        protected override void onBeforeInsert(List<SObject> newList) {
            DAOH_UserProjectAllocation.validateInsert(newList);
        }

        /**
         * On before update - validate that User or Project fields were not changed.
         * @param newList - Trigger.new
         * @param oldMap - Trigger.oldMap
         */
        protected override void onBeforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            DAOH_UserProjectAllocation.validateUpdate(newList, (Map<Id, User_Project_Allocation__c>) oldMap);
        }

        /**
         * On after insert - add sharing for Project-related records.
         * @param newList - Trigger.new
         */
        protected override void onAfterInsert(List<SObject> newList) {
            DAOH_UserProjectAllocation.processSharing(newList, null);
        }

        /**
         * On after update - process sharing for Project-related records.
         * Add sharing if Status was changed to Active, remove sharing if Status was changed to Inactive.
         * @param newList - Trigger.new
         * @param oldMap - Trigger.oldMap
         */
        protected override void onAfterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            DAOH_UserProjectAllocation.processSharing(newList, (Map<Id, User_Project_Allocation__c>) oldMap);
        }

        /**
         * On after update - remove sharing from Project-related records.
         * @param oldList - Trigger.old
         */
        protected override void onAfterDelete(List<SObject> oldList) {
            DAOH_UserProjectAllocation.removeSharing(oldList);
        }
    }

    public class SharingForceRecalculationHandler extends DAO_TriggerHandler {
        /**
         * On after update - process sharing for Project-related records.
         * If RecalculateSharing field was checked - calculate sharing once again.
         * @param newList - Trigger.new
         * @param oldMap - Trigger.oldMap
         */
        protected override void onAfterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            DAOH_UserProjectAllocation.processRecalculationField(newList, (Map<Id, User_Project_Allocation__c>) oldMap);
        }
    }
}