/*
*This trigger is used for FRUP(box) object 
*/
trigger TGR_box_FRUP on box__FRUP__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_box_FRUP__c){
        fflib_SObjectDomain.triggerHandler(DAO_box_FRUP.class);  
    }
}