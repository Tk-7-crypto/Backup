/**
* This trigger is used for Miscellaneous Adjustment object.
* version : 1.0
*/
trigger TGR_Miscellaneous_Adjustment on pse__Miscellaneous_Adjustment__c (before insert, before update,before delete, after insert, after update, after delete) {
    if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_Miscellaneous_Adjustment_Trigger__c){
        fflib_SObjectDomain.triggerHandler(DAO_Miscellaneous_Adjustment.class); 
    }
}