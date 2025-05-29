trigger TGR_LineItem on Apttus_Config2__LineItem__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if (Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_Cart_Line_Item_Trigger__c) {
        fflib_SObjectDomain.triggerHandler(DAO_LineItem.class);
    }
}