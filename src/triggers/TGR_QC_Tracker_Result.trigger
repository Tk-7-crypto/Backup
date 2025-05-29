/**
 * This trigger is used for QC Tracker Result(QC_Tracker_Result__c) object.
 * version : 1.0
 */
trigger TGR_QC_Tracker_Result on QC_Tracker_Result__c (before insert, before update, after insert, after update) {
    if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_PSA_QC_Tracker_Result_Trigger__c) {
        fflib_SObjectDomain.triggerHandler(DAO_QC_Tracker_Result.class);
    } 
}
