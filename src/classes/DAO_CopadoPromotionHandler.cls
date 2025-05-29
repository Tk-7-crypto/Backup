/**
 * @author Vlad Tyazhov
 * Apex handler for copado__Promotion__c trigger.
 * Share record with users based on User_Project_Allocation__c records.
 */
public without sharing class DAO_CopadoPromotionHandler {
    public class SharingHandler extends DAO_TriggerHandler {
        /**
         * On After Insert - share Promotions with project allocated users
         * @param newList - Trigger.new
         */
        protected override void onAfterInsert(List<SObject> newList) {
            DAOH_UserProjectAllocation.shareToAllocatedUsers((List<copado__Promotion__c>) newList);
        }
    }
}